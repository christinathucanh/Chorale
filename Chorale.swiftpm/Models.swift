//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation

enum Mood: Int, Codable, CaseIterable, Identifiable {
    case veryLow = 1
    case low = 2
    case neutral = 3
    case good = 4
    case great = 5

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .neutral: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        }
    }

    var emoji: String {
        switch self {
        case .veryLow: return "😞"
        case .low: return "😕"
        case .neutral: return "😐"
        case .good: return "🙂"
        case .great: return "😄"
        }
    }

    var colorName: String {
        // Used by AccentColor mapping
        switch self {
        case .veryLow: return "mood1"
        case .low: return "mood2"
        case .neutral: return "mood3"
        case .good: return "mood4"
        case .great: return "mood5"
        }
    }
}

struct MoodEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var mood: Mood
    var tags: [String]
    var note: String
    var didBreathe: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: Mood,
        tags: [String] = [],
        note: String = "",
        didBreathe: Bool = false
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.tags = tags
        self.note = note
        self.didBreathe = didBreathe
    }
}

struct Insight: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let detail: String
    let symbol: String
}
