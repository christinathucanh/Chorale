//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct MoodMusicVisualizer: View {
    let mood: Mood
    let isPlaying: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Mood Sound")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.text)
                Spacer()
                Text(isPlaying ? "Playing" : "Stopped")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.10))
                    .clipShape(Capsule())
            }

            VisualizerBars(mood: mood, isPlaying: isPlaying)
                .frame(height: 70)
                .accessibilityHidden(true)

            Text("Tone changes with your mood — a tiny ambient chord + motion.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.subtext)
        }
        .glassCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Mood Sound")
        .accessibilityValue(isPlaying ? "Playing" : "Stopped")
        .accessibilityHint("Plays an ambient tone that changes with your selected mood.")

    }
}

private struct VisualizerBars: View {
    let mood: Mood
    let isPlaying: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var intensity: Double {
        switch mood {
        case .veryLow: return 0.35
        case .low: return 0.45
        case .neutral: return 0.60
        case .good: return 0.75
        case .great: return 0.95
        }
    }

    private var speed: Double {
        switch mood {
        case .veryLow: return 0.70
        case .low: return 0.85
        case .neutral: return 1.00
        case .good: return 1.15
        case .great: return 1.35
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let base = isPlaying ? 1.0 : 0.15
            
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<18, id: \.self) { i in
                    let phase = t * speed + Double(i) * 0.35
                    let wave = (sin(phase) + 1) / 2 // 0..1
                    let h = (0.15 + wave * intensity) * base

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.65))
                        .frame(maxWidth: .infinity)
                        .scaleEffect(x: 1, y: h, anchor: .bottom)
                        .animation(.linear(duration: 0.08), value: h)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
        }
    }
}
