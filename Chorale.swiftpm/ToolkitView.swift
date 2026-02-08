//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct ToolkitView: View {
    @State private var showBoxBreathing = false
    @State private var showBodyScan = false
    @State private var show54321 = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Toolkit")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.text)

                        Text("Fast ways to calm your nervous system and come back to the present.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.subtext)

                        ButtonCard(
                            icon: "square.grid.3x3.fill",
                            title: "5-4-3-2-1 Grounding",
                            subtitle: "Name senses to reduce spirals"
                        ) { show54321 = true }

                        ButtonCard(
                            icon: "rectangle.expand.vertical",
                            title: "Box Breathing",
                            subtitle: "4 • 4 • 4 • 4 rhythm"
                        ) { showBoxBreathing = true }

                        ButtonCard(
                            icon: "figure.mind.and.body",
                            title: "60-second Body Scan",
                            subtitle: "Release tension top-to-bottom"
                        ) { showBodyScan = true }

                        Spacer(minLength: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("")
            .sheet(isPresented: $show54321) { Grounding54321Sheet() }
            .sheet(isPresented: $showBoxBreathing) { BoxBreathingSheet() }
            .sheet(isPresented: $showBodyScan) { BodyScanSheet() }
        }
    }
}

private struct ButtonCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.text)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.subtext)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

private struct Grounding54321Sheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("5-4-3-2-1 Grounding")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.text)

                        StepLine(n: "5", text: "Name 5 things you can SEE.")
                        StepLine(n: "4", text: "Name 4 things you can FEEL (touch).")
                        StepLine(n: "3", text: "Name 3 things you can HEAR.")
                        StepLine(n: "2", text: "Name 2 things you can SMELL.")
                        StepLine(n: "1", text: "Name 1 thing you can TASTE (or like).")

                        Text("Tip: Say them out loud. Slow down between each number.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.subtext)
                            .padding(.top, 6)
                    }
                    .padding(16)
                }
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

private struct StepLine: View {
    let n: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(n)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 26)
            Text(text)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.text)
            Spacer()
        }
        .glassCard()
    }
}

private struct BoxBreathingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var running = false
    @State private var phaseIndex = 0
    @State private var secondsLeft = 4

    private let phases = ["Inhale", "Hold", "Exhale", "Hold"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                VStack(spacing: 14) {
                    Text("Box Breathing")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.text)

                    Text("4 seconds each phase. Repeat 4 times.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.subtext)

                    VStack(spacing: 8) {
                        Text(phases[phaseIndex])
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("\(secondsLeft)")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.12), lineWidth: 1))

                    HStack(spacing: 10) {
                        Button {
                            Haptics.tap()
                            running.toggle()
                            if running { tick() }
                        } label: {
                            Label(running ? "Pause" : "Start", systemImage: running ? "pause.fill" : "play.fill")
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

                    Spacer()
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func reset() {
        running = false
        phaseIndex = 0
        secondsLeft = 4
    }

    private func tick() {
        guard running else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard running else { return }
            if secondsLeft > 1 {
                secondsLeft -= 1
            } else {
                secondsLeft = 4
                phaseIndex = (phaseIndex + 1) % phases.count
            }
            tick()
        }
    }
}

private struct BodyScanSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let steps = [
        "Forehead & jaw: unclench.",
        "Shoulders: drop them 1 inch.",
        "Chest: slow the breath.",
        "Hands: soften grip.",
        "Belly: allow it to relax.",
        "Legs: feel the ground.",
        "Feet: notice contact points."
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("60-second Body Scan")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.text)

                        Text("Read slowly. Pause after each line.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.subtext)

                        ForEach(steps, id: \.self) { s in
                            Text("• \(s)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.text)
                                .glassCard()
                        }

                        Text("Finish: one slow exhale, longer than the inhale.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.subtext)
                            .padding(.top, 8)
                    }
                    .padding(16)
                }
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
