//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct MoodMapView: View {
    @EnvironmentObject private var store: MoodStore

    @State private var monthOffset: Int = 0
    @State private var selectedEntry: MoodEntry?
    @State private var selectedTag: String? = nil

    private var allTags: [String] {
        let set = Set(store.entries.flatMap { $0.tags })
        return set.sorted()
    }
    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Filter by tag")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.subtext)

                Spacer()

                if selectedTag != nil {
                    Button("Clear") {
                        Haptics.tap()
                        selectedTag = nil
                        selectedEntry = nil
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    
                }
            }

            if allTags.isEmpty {
                Text("No tags yet. Add tags in check-ins to filter.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.subtext)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        tagChip(title: "All", isSelected: selectedTag == nil) {
                            Haptics.tap()
                            selectedTag = nil
                            selectedEntry = nil
                        }

                        ForEach(allTags, id: \.self) { t in
                            tagChip(title: t, isSelected: selectedTag == t) {
                                Haptics.tap()
                                selectedTag = t
                                selectedEntry = nil
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .glassCard()
    }

    private func tagChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.10))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(isSelected ? 0.35 : 0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func accessibleDayLabel(day: Date, entry: MoodEntry?) -> String {
        let df = DateFormatter()
        df.dateStyle = .full
        let dateStr = df.string(from: day)

        guard let entry else { return "\(dateStr). No entry." }
        let breathe = entry.didBreathe ? "Breathed." : ""
        let tags = entry.tags.isEmpty ? "" : "Tags: \(entry.tags.joined(separator: ", "))."
        return "\(dateStr). Mood: \(entry.mood.title). \(breathe) \(tags)"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 14) {
                    header
                    filterBar
                    monthGrid

                    if let entry = selectedEntry {
                        entryDetail(entry)
                            .transition(.opacity)
                    } else {
                        Text("Tap a day to view details.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.subtext)
                            .padding(.horizontal, 2)
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mood Map")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.text)
                Text("A calendar view of your mood check-ins.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.subtext)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    Haptics.tap()
                    monthOffset -= 1
                    selectedEntry = nil
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    Haptics.tap()
                    monthOffset += 1
                    selectedEntry = nil
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var monthGrid: some View {
        let month = currentMonthDate()
        let title = monthTitle(month)

        return VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.text)

            let days = calendarDays(forMonthContaining: month)

            VStack(spacing: 8) {
                // Weekday header
                HStack(spacing: 8) {
                    ForEach(["S","M","T","W","T","F","S"], id: \.self) { s in
                        Text(s)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AppTheme.subtext)
                            .frame(maxWidth: .infinity)
                    }
                }

                // 6 rows x 7 cols
                ForEach(0..<6, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<7, id: \.self) { col in
                            let idx = row * 7 + col
                            if idx < days.count, let day = days[idx] {
                                dayCell(day)
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.04))
                                    .frame(height: 42)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
            }
        }
        .glassCard()
    }

    private func dayCell(_ day: Date) -> some View {
        let isInMonth = Calendar.current.isDate(day, equalTo: currentMonthDate(), toGranularity: .month)

        let entry = store.entries.first {
            Calendar.current.isDate($0.date, inSameDayAs: day)
            && (selectedTag == nil || $0.tags.contains(selectedTag!))
        }


        return Button {
            Haptics.tap()
            selectedEntry = entry
        } label: {
            VStack(spacing: 6) {
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isInMonth ? AppTheme.text : AppTheme.subtext.opacity(0.5))

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(entry == nil ? 0.10 : 0.18))
                        .frame(width: 18, height: 18)

                    if let entry = entry {
                        Text(entry.mood.emoji)
                            .font(.system(size: 14))
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(Color.white.opacity(isInMonth ? 0.06 : 0.03))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func entryDetail(_ entry: MoodEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.mood.emoji)
                    .font(.system(size: 26))
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayTitle(entry.date))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppTheme.text)
                    Text(entry.mood.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.subtext)
                }
                Spacer()
                if entry.didBreathe {
                    Label("Breathed", systemImage: "wind")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }

            let text = entry.note.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            if text.isEmpty {
                Text("No notes for this day.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.subtext)
            } else {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.text)
            }

        }
        .glassCard()
    }

    // MARK: - Calendar helpers

    private func currentMonthDate() -> Date {
        let base = Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
        let comps = Calendar.current.dateComponents([.year, .month], from: base)
        return Calendar.current.date(from: comps) ?? base
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private func dayTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: date)
    }

    private func calendarDays(forMonthContaining monthStart: Date) -> [Date?] {
        let cal = Calendar.current
        let startOfMonth = monthStart
        guard let range = cal.range(of: .day, in: .month, for: startOfMonth) else { return [] }

        // Determine weekday offset for first day
        let firstWeekday = cal.component(.weekday, from: startOfMonth) // 1=Sun
        let leadingBlanks = firstWeekday - 1

        var result: [Date?] = Array(repeating: nil, count: leadingBlanks)

        for day in range {
            if let d = cal.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                result.append(d)
            }
        }

        // pad to 42 cells (6 weeks)
        while result.count < 42 { result.append(nil) }
        return result
    }
}
