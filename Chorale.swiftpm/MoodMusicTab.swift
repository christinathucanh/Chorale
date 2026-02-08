//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct MoodMusicTab: View {
    @State private var showMoodSound = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                VStack(spacing: 16) {
                    // Logo header
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )

                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.95))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mood → Music")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.text)

                            Text("Ambient soundscape driven by mood")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppTheme.subtext)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Button {
                        Haptics.tap()
                        showMoodSound = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                            Text("Open Visualizer")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.white.opacity(0.35))
                        }
                        .foregroundStyle(.white)
                        .glassCard()
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
            .sheet(isPresented: $showMoodSound) {
                MoodSoundSheet()
            }
            .navigationTitle("")
        }
    }
}
