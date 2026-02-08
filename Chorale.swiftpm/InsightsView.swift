//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var store: MoodStore
    @State private var rangeDays: Int = 14

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        header

                        rangePicker

                        trendCard

                        tagsCard

                        insightCards

                        Spacer(minLength: 24)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Insights")
            .foregroundStyle(.white)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Patterns, not judgments.")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.text)
            Text("These insights are computed locally on-device.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.subtext)
        }
    }

    private var rangePicker: some View {
        HStack(spacing: 10) {
            Text("Range")
                .foregroundStyle(AppTheme.subtext)
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Picker("", selection: $rangeDays) {
                Text("7d").tag(7)
                Text("14d").tag(14)
                Text("30d").tag(30)
            }
            .pickerStyle(.segmented)
            .frame(width: 220)
        }
        .glassCard()
    }

    private var trendCard: some View {
        let recent = store.entries(inLastDays: rangeDays).sorted { $0.date < $1.date }
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Mood trend", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.text)
                Spacer()
                Text("\(rangeDays)d")
                    .foregroundStyle(AppTheme.subtext)
                    .font(.system(size: 13, weight: .semibold))
            }

            if recent.isEmpty {
                Text("Log a few check-ins to see your trend.")
                    .foregroundStyle(AppTheme.subtext)
                    .font(.system(size: 13))
            } else {
                MiniTrend(entries: recent)
                    .frame(height: 70)
            }

            if let avg = store.averageMood(inLastDays: rangeDays) {
                Text("Average: \(String(format: "%.1f", avg))/5")
                    .foregroundStyle(AppTheme.subtext)
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .glassCard()
    }

    private var tagsCard: some View {
        let tags = store.topTags(inLastDays: rangeDays, limit: 8)
        return VStack(alignment: .leading, spacing: 10) {
            Label("Top tags", systemImage: "tag.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.text)

            if tags.isEmpty {
                Text("Add tags like “sleep”, “school”, “friends”.")
                    .foregroundStyle(AppTheme.subtext)
                    .font(.system(size: 13))
            } else {
                TagWrap(tags: tags.map { "\($0.0) • \($0.1)" })
            }
        }
        .glassCard()
    }

    private var insightCards: some View {
        let insights = store.insights(inLastDays: rangeDays)
        return VStack(alignment: .leading, spacing: 10) {
            ForEach(insights) { ins in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: ins.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .frame(width: 26)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ins.title)
                            .foregroundStyle(AppTheme.text)
                            .font(.system(size: 15, weight: .bold))
                        Text(ins.detail)
                            .foregroundStyle(AppTheme.subtext)
                            .font(.system(size: 13))
                    }
                    Spacer()
                }
                .glassCard()
            }
        }
    }
}
