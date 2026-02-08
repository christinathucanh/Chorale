import Foundation
import AVFoundation
import os.lock

/// Offline ambient synth + visualizer driver.
/// Thread-safe: UI thread updates targets, audio thread reads via lock.
final class MusicEngine: ObservableObject, @unchecked Sendable {
    static let shared = MusicEngine()

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?

    private var format: AVAudioFormat!
    private var sampleRate: Double = 44_100

    // Oscillator phases (audio thread only)
    private var phase: [Double] = [0, 0, 0]
    private var freqs: [Double] = [220, 277.18, 329.63] // current freqs (audio thread only)
    private var amp: Double = 0.0                       // current amp (audio thread only)
    private var lfoPhase: Double = 0                    // audio thread only

    // Shared targets (UI writes, audio reads) — protected by lock
    private var lock = os_unfair_lock_s()
    private var targetFreqs: [Double] = [220, 277.18, 329.63]
    private var targetArpRate: Double = 0.35   // notes per second

    private var targetAmp: Double = 0.0
    private var targetLfoRate: Double = 0.15

    private init() {
        configureAudioSession()
        setupEngine()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // Playgrounds can be finicky; keep going.
        }
    }

    private func setupEngine() {
        // Force Float32 stereo (non-interleaved). This avoids RemoteIO format surprises.
        sampleRate = 44_100
        format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)

        let node = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }

            // Copy targets under lock (fast, safe)
            var localTargetFreqs: [Double] = [220, 277.18, 329.63]
            var localTargetAmp: Double = 0
            var localLfoRate: Double = 0.15
            var localArpRate: Double = 0.35

            os_unfair_lock_lock(&self.lock)
            localTargetFreqs = self.targetFreqs
            localTargetAmp = self.targetAmp
            localLfoRate = self.targetLfoRate
            localArpRate = self.targetArpRate

            os_unfair_lock_unlock(&self.lock)

            // Slew to targets (prevents zipper noise)
            let freqSlew = 0.01
            for i in 0..<min(self.freqs.count, localTargetFreqs.count) {
                self.freqs[i] += (localTargetFreqs[i] - self.freqs[i]) * freqSlew
            }
            self.amp += (localTargetAmp - self.amp) * 0.002

            let twoPi = 2.0 * Double.pi
            let sr = self.sampleRate
            let lfoInc = twoPi * localLfoRate / sr
            
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                self.lfoPhase += lfoInc
                if self.lfoPhase > twoPi { self.lfoPhase -= twoPi }
                let lfo = 0.75 + 0.25 * sin(self.lfoPhase)
                

                var s: Double = 0.0
                for osc in 0..<self.freqs.count {
                    let inc = twoPi * self.freqs[osc] / sr
                    self.phase[osc] += inc
                    if self.phase[osc] > twoPi { self.phase[osc] -= twoPi }

                    let w = (osc == 0) ? 0.55 : (osc == 1 ? 0.30 : 0.22)
                    s += sin(self.phase[osc]) * w
                }

                var out = s * self.amp * lfo
                out = max(-0.9, min(0.9, out))
                let f = Float(out)

                // Write mono sample to each channel buffer safely
                for buf in abl {
                    guard let mData = buf.mData else { continue }
                    let ptr = mData.bindMemory(to: Float.self, capacity: Int(frameCount))
                    ptr[frame] = f
                }
            }

            return noErr
        }

        sourceNode = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.9
    }

    // MARK: - Public API (call from UI)

    func start(mood: Mood) {
        setMood(mood)
        setTargetAmp(0.18)

        if !engine.isRunning {
            do { try engine.start() } catch { /* ignore */ }
        }
    }

    func stop() {
        // Fade out (slewed in render thread)
        setTargetAmp(0.0)

        // Stop engine safely on a short delay to allow fade to reach near-zero.
        // Using stop() (not pause) avoids some RemoteIO assert patterns.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self = self else { return }
            self.engine.stop()
        }
    }

    func setMood(_ mood: Mood) {
        let freqs: [Double]
        let rate: Double
        let amp: Double

        switch mood {
        case .veryLow:
            // Low, hollow, unstable
            freqs = [110.0, 146.83, 174.61]   // A2 D3 F3
            rate = 0.08
            amp = 0.14

        case .low:
            // Minor, grounded
            freqs = [164.81, 196.00, 246.94]  // E G B
            rate = 0.11
            amp = 0.16

        case .neutral:
            // Open, suspended
            freqs = [196.00, 220.00, 293.66]  // G A D
            rate = 0.15
            amp = 0.17

        case .good:
            // Warm major
            freqs = [261.63, 329.63, 392.00]  // C E G
            rate = 0.20
            amp = 0.19

        case .great:
            // Bright, uplifting
            freqs = [220.00, 277.18, 440.00]  // A C# A (octave)
            rate = 0.28
            amp = 0.22
        }

        os_unfair_lock_lock(&lock)
        targetFreqs = freqs
        targetLfoRate = rate
        targetAmp = amp
        os_unfair_lock_unlock(&lock)
    }


    // MARK: - Helpers

    private func setTargetAmp(_ value: Double) {
        os_unfair_lock_lock(&lock)
        targetAmp = value
        os_unfair_lock_unlock(&lock)
    }
}
