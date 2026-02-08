//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: MoodStore
    @State private var reminderOn = false
    @State private var reminderTime = Date()
    @State private var showShare = false
    @State private var permissionStatusText = "Not requested"

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        Text("Settings")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.text)

                        reminderCard
                        exportCard
                        achievementsCard

                        Spacer(minLength: 30)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("")
            .sheet(isPresented: $showShare) {
                let json = store.exportJSONString(pretty: true)
                ShareSheet(items: [json])
            }
            .onAppear {
                // default reminder time 9:00 if not set
                if Calendar.current.component(.hour, from: reminderTime) == 0 && Calendar.current.component(.minute, from: reminderTime) == 0 {
                    reminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
                }
            }
        }
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Daily reminder", systemImage: "bell.fill")
                    .foregroundStyle(AppTheme.text)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Toggle("", isOn: $reminderOn)
                    .labelsHidden()
                    .onChange(of: reminderOn) { _ in
                        Haptics.tap()
                        if reminderOn {
                            Notifier.requestPermission { ok in
                                permissionStatusText = ok ? "Allowed" : "Denied"
                                if ok {
                                    scheduleFromDate(reminderTime)
                                } else {
                                    reminderOn = false
                                }
                            }
                        } else {
                            Notifier.cancelDailyReminder()
                        }
                    }
            }

            DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .tint(.white)
                .onChange(of: reminderTime) { _ in
                    if reminderOn {
                        scheduleFromDate(reminderTime)
                    }
                }

            Text("Permission: \(permissionStatusText)")
                .foregroundStyle(AppTheme.subtext)
                .font(.system(size: 13, weight: .medium))
        }
        .glassCard()
    }

    private var exportCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Export data", systemImage: "square.and.arrow.up")
                .foregroundStyle(AppTheme.text)
                .font(.system(size: 15, weight: .semibold))

            Text("Share your entries as JSON (offline, private).")
                .foregroundStyle(AppTheme.subtext)
                .font(.system(size: 13, weight: .medium))

            Button {
                Haptics.tap()
                showShare = true
            } label: {
                HStack {
                    Spacer()
                    Text("Share JSON")
                        .font(.system(size: 15, weight: .bold))
                        .padding(.vertical, 10)
                    Spacer()
                }
                .foregroundStyle(.black)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .glassCard()
    }

    private var achievementsCard: some View {
        let streak = store.currentStreak()
        let achievements = Achievements.make(
            streak: streak,
            entriesCount: store.entries.count,
            breathingCount: store.totalBreathingCount()
        )

        return VStack(alignment: .leading, spacing: 10) {
            Label("Achievements", systemImage: "trophy.fill")
                .foregroundStyle(AppTheme.text)
                .font(.system(size: 15, weight: .semibold))

            ForEach(achievements) { a in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: a.symbol)
                        .foregroundStyle(a.unlocked ? .white : .white.opacity(0.35))
                        .frame(width: 22)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(a.title)
                            .foregroundStyle(a.unlocked ? AppTheme.text : AppTheme.subtext)
                            .font(.system(size: 14, weight: .bold))
                        Text(a.detail)
                            .foregroundStyle(AppTheme.subtext)
                            .font(.system(size: 12, weight: .medium))
                    }
                    Spacer()

                    if a.unlocked {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .padding(10)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.10), lineWidth: 1))
            }
        }
        .glassCard()
    }

    private func scheduleFromDate(_ date: Date) {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        Notifier.scheduleDailyReminder(hour: hour, minute: minute)
    }
}
