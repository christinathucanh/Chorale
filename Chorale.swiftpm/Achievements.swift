//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation

struct Achievement: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let detail: String
    let symbol: String
    let unlocked: Bool
}

enum Achievements {
    static func make(streak: Int, entriesCount: Int, breathingCount: Int) -> [Achievement] {
        [
            Achievement(
                title: "First Check-in",
                detail: "Log your first entry.",
                symbol: "checkmark.seal.fill",
                unlocked: entriesCount >= 1
            ),
            Achievement(
                title: "Three-Day Streak",
                detail: "Check in 3 days in a row.",
                symbol: "flame.fill",
                unlocked: streak >= 3
            ),
            Achievement(
                title: "One Week Streak",
                detail: "Check in 7 days in a row.",
                symbol: "flame.circle.fill",
                unlocked: streak >= 7
            ),
            Achievement(
                title: "Breathing Buddy",
                detail: "Do 5 breathing-marked check-ins.",
                symbol: "wind",
                unlocked: breathingCount >= 5
            ),
            Achievement(
                title: "Consistency",
                detail: "Log 20 total entries.",
                symbol: "calendar.badge.clock",
                unlocked: entriesCount >= 20
            )
        ]
    }
}
