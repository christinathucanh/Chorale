//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct BreathingSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var didFinish = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("Breathe")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.text)

                    Text("Inhale • Hold • Exhale\nFollow the circle for 60 seconds.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.subtext)

                    BreathingView(totalSeconds: 60) {
                        Haptics.success()
                        didFinish = true
                    }
                    .padding(.top, 10)

                    if didFinish {
                        Text("Nice. You showed up for yourself.")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppTheme.text)
                            .padding(.top, 6)
                    }

                    Spacer(minLength: 0)
                }
                .padding(18)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

struct BreathingView: View {
    let totalSeconds: Int
    var onComplete: () -> Void

    @State private var phase: Phase = .inhale
    @State private var progress: Double = 0
    @State private var remaining: Int = 0
    @State private var isRunning = false

    enum Phase: String {
        case inhale = "Inhale"
        case hold = "Hold"
        case exhale = "Exhale"

        var hint: String {
            switch self {
            case .inhale: return "Fill your lungs gently."
            case .hold: return "Soften your shoulders."
            case .exhale: return "Let it out slowly."
            }
        }
    }

    // A calm pattern: 4 inhale, 2 hold, 6 exhale (12s loop)
    private let inhaleDur = 4
    private let holdDur = 2
    private let exhaleDur = 6

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: max(0.001, progress))
                    .stroke(Color.white.opacity(0.70), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.25), value: progress)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.20), Color.white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 220, height: 220)
                    .scaleEffect(circleScale)
                    .animation(.easeInOut(duration: 0.9), value: phase)

                VStack(spacing: 6) {
                    Text(phase.rawValue)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(phase.hint)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    Text(timeLabel)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .padding(.top, 4)
                }
            }

            HStack(spacing: 10) {
                Button {
                    Haptics.tap()
                    toggle()
                } label: {
                    Label(isRunning ? "Pause" : "Start", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    Haptics.warning()
                    reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .onAppear {
            reset()
        }
    }

    private var circleScale: CGFloat {
        switch phase {
        case .inhale: return 1.10
        case .hold: return 1.10
        case .exhale: return 0.88
        }
    }

    private var timeLabel: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private func reset() {
        isRunning = false
        remaining = totalSeconds
        phase = .inhale
        progress = 0
    }

    private func toggle() {
        isRunning.toggle()
        if isRunning {
            tickLoop()
        }
    }

    private func tickLoop() {
        guard isRunning else { return }
        guard remaining > 0 else {
            isRunning = false
            onComplete()
            return
        }

        // Update progress: 0 -> 1 over total seconds
        let done = Double(totalSeconds - remaining)
        progress = min(1.0, done / Double(totalSeconds))

        // Update phase based on a 12s breathing cycle
        let cycle = inhaleDur + holdDur + exhaleDur
        let elapsed = totalSeconds - remaining
        let t = elapsed % cycle

        if t < inhaleDur {
            phase = .inhale
        } else if t < inhaleDur + holdDur {
            phase = .hold
        } else {
            phase = .exhale
        }

        remaining -= 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            tickLoop()
        }
    }
}
