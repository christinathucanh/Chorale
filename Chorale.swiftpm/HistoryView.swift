//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: MoodStore
    @State private var query: String = ""
    @State private var selected: MoodEntry? = nil

    var filtered: [MoodEntry] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return store.entries }
        return store.entries.filter { e in
            e.note.lowercased().contains(q) ||
            e.tags.contains(where: { $0.lowercased().contains(q) }) ||
            e.mood.title.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                VStack(spacing: 10) {
                    SearchBar(text: $query)

                    if filtered.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(AppTheme.subtext)
                            Text("No matches")
                                .foregroundStyle(AppTheme.text)
                                .font(.system(size: 16, weight: .semibold))
                            Text("Try searching a tag like “sleep”.")
                                .foregroundStyle(AppTheme.subtext)
                                .font(.system(size: 13))
                        }
                        .padding(.top, 40)
                        Spacer()
                    } else {
                        List {
                            ForEach(filtered) { entry in
                                Button {
                                    Haptics.tap()
                                    selected = entry
                                } label: {
                                    EntryRow(entry: entry)
                                        .listRowBackground(AppTheme.bg)
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { idxSet in
                                for idx in idxSet {
                                    let entry = filtered[idx]
                                    store.delete(entry)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .padding(.top, 10)
            }
            .navigationTitle("History")
            .foregroundStyle(.white)
            .sheet(item: $selected) { entry in
                EntryDetailSheet(entry: entry)
            }
        }
    }
}

struct EntryDetailSheet: View {
    @EnvironmentObject private var store: MoodStore
    @Environment(\.dismiss) private var dismiss

    @State var entry: MoodEntry

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            Text(entry.mood.emoji).font(.system(size: 44))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.mood.title)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.text)
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(AppTheme.subtext)
                            }
                            Spacer()
                        }
                        .glassCard()

                        if !entry.tags.isEmpty {
                            TagWrap(tags: entry.tags)
                                .glassCard()
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.text)
                            Text(entry.note.isEmpty ? "—" : entry.note)
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.subtext)
                        }
                        .glassCard()

                        HStack {
                            Label(entry.didBreathe ? "Breathing: Yes" : "Breathing: No", systemImage: entry.didBreathe ? "wind" : "wind")
                                .foregroundStyle(AppTheme.subtext)
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                        }
                        .glassCard()

                        Button(role: .destructive) {
                            Haptics.warning()
                            store.delete(entry)
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Label("Delete Entry", systemImage: "trash.fill")
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.red.opacity(0.5), lineWidth: 1))
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 24)
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
