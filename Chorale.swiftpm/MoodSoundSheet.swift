//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct MoodSoundSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: Mood = .neutral
    @State private var playing = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Mood → Music")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.text)

                        Text("Pick a mood. Hear an ambient chord. Watch it move.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.subtext)

                        moodPicker

                        MoodMusicVisualizer(mood: selectedMood, isPlaying: playing)

                        controls
                    }
                    .padding(16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        stopIfNeeded()
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .onDisappear { stopIfNeeded() }
        }
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.subtext)

            HStack(spacing: 10) {
                ForEach(Mood.allCases) { m in
                    Button {
                        Haptics.tap()
                        selectedMood = m
                        if playing { MusicEngine.shared.setMood(m) }
                    } label: {
                        VStack(spacing: 6) {
                            Text(m.emoji).font(.system(size: 22))
                            Text("\(m.rawValue)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(m.title) mood")
                        .accessibilityValue(m == selectedMood ? "Selected" : "")
                        .accessibilityHint("Double tap to select this mood.")
                        .accessibilityAddTraits(m == selectedMood ? [.isButton, .isSelected] : .isButton)

                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(m == selectedMood ? Color.white.opacity(0.14) : AppTheme.card2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(m == selectedMood ? Color.white.opacity(0.35) : AppTheme.stroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(selectedMood.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.text)
        }
        .glassCard()
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button {
                Haptics.tap()
                if playing {
                    MusicEngine.shared.stop()
                    playing = false
                } else {
                    MusicEngine.shared.start(mood: selectedMood)
                    playing = true
                }
            } label: {
                Label(playing ? "Stop" : "Play", systemImage: playing ? "stop.fill" : "play.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                Haptics.warning()
                selectedMood = .neutral
                if playing { MusicEngine.shared.setMood(.neutral) }
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Spacer()
        }
        .padding(.top, 4)
    }

    private func stopIfNeeded() {
        if playing {
            MusicEngine.shared.stop()
            playing = false
        }
    }
}
