//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

@MainActor
final class MoodStore: ObservableObject {
    @Published private(set) var entries: [MoodEntry] = []
    @Published var lastSavedAt: Date? = nil

    private let persistence = Persistence(filename: "mood_entries.json")

    init() {
        load()
        seedIfFirstLaunch()
    }

    func load() {
        do {
            let loaded: [MoodEntry] = try persistence.load([MoodEntry].self)
            self.entries = loaded.sorted { $0.date > $1.date }
        } catch {
            self.entries = []
        }
    }
    func exportJSONString(pretty: Bool = true) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = pretty ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]

        do {
            let data = try encoder.encode(entries)
            return String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            return "[]"
        }
    }

    func totalBreathingCount() -> Int {
        entries.filter { $0.didBreathe }.count
    }


    func save() {
        do {
            try persistence.save(entries)
            lastSavedAt = Date()
        } catch {
            
        }
    }

    func add(_ entry: MoodEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func delete(_ entry: MoodEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func update(_ entry: MoodEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        entries.sort { $0.date > $1.date }
        save()
    }

    // MARK: - Queries

    func entries(inLastDays days: Int) -> [MoodEntry] {
        let start = Calendar.current.date(byAdding: .day, value: -days + 1, to: Date()) ?? Date()
        return entries.filter { $0.date >= start }
    }

    func averageMood(inLastDays days: Int) -> Double? {
        let recent = entries(inLastDays: days)
        guard !recent.isEmpty else { return nil }
        let sum = recent.reduce(0) { $0 + $1.mood.rawValue }
        return Double(sum) / Double(recent.count)
    }

    func topTags(inLastDays days: Int, limit: Int = 6) -> [(String, Int)] {
        let recent = entries(inLastDays: days)
        var counts: [String: Int] = [:]
        for e in recent {
            for t in e.tags where !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                counts[t, default: 0] += 1
            }
        }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }

    func insights(inLastDays days: Int = 14) -> [Insight] {
        let recent = entries(inLastDays: days)
        guard !recent.isEmpty else {
            return [
                Insight(title: "Start with a check-in", detail: "Log one entry to unlock patterns and insights.", symbol: "sparkles")
            ]
        }

        var output: [Insight] = []

        if let avg = averageMood(inLastDays: min(days, 7)) {
            let rounded = String(format: "%.1f", avg)
            output.append(
                Insight(
                    title: "Your recent average",
                    detail: "In the last 7 days, your average mood is \(rounded)/5.",
                    symbol: "chart.line.uptrend.xyaxis"
                )
            )
        }

        let breatheCount = recent.filter { $0.didBreathe }.count
        if breatheCount > 0 {
            output.append(
                Insight(
                    title: "Breathing helps you show up",
                    detail: "\(breatheCount) of your last \(recent.count) check-ins were after a breathing session.",
                    symbol: "wind"
                )
            )
        }

        let tagPairs = topTags(inLastDays: days, limit: 3)
        if !tagPairs.isEmpty {
            let formatted = tagPairs.map { "#\($0.0) (\($0.1))" }.joined(separator: ", ")
            output.append(
                Insight(
                    title: "Themes you’ve been feeling",
                    detail: formatted,
                    symbol: "tag"
                )
            )
        }

        // Streak
        let streak = currentStreak()
        if streak >= 3 {
            output.append(
                Insight(
                    title: "Consistency streak",
                    detail: "You’ve checked in \(streak) days in a row. Keep it gentle and doable.",
                    symbol: "flame"
                )
            )
        } else {
            output.append(
                Insight(
                    title: "Small wins count",
                    detail: "Try a 30-second check-in today. Momentum beats intensity.",
                    symbol: "checkmark.seal"
                )
            )
        }

        return output
    }

    func currentStreak() -> Int {
        guard !entries.isEmpty else { return 0 }
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: Date())

        while true {
            let hasEntryThatDay = entries.contains { cal.isDate($0.date, inSameDayAs: day) }
            if hasEntryThatDay {
                streak += 1
                guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
                day = prev
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Demo seed (optional)

    private func seedIfFirstLaunch() {
        guard entries.isEmpty else { return }
        // A tiny seed so the UI doesn’t look empty on first run.
        let cal = Calendar.current
        let now = Date()
        let sample: [MoodEntry] = [
            MoodEntry(date: cal.date(byAdding: .day, value: -1, to: now) ?? now, mood: .good, tags: ["sleep", "friends"], note: "Felt lighter after talking.", didBreathe: true),
            MoodEntry(date: cal.date(byAdding: .day, value: -2, to: now) ?? now, mood: .neutral, tags: ["school"], note: "A bit scattered but okay.", didBreathe: false),
            MoodEntry(date: cal.date(byAdding: .day, value: -3, to: now) ?? now, mood: .low, tags: ["stress"], note: "Overthinking day.", didBreathe: true)
        ]
        entries = sample.sorted { $0.date > $1.date }
        save()
    }
}
