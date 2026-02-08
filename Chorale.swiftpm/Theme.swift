//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

enum AppTheme {
    static let bg = Color.black.opacity(0.92)
    static let card = Color.white.opacity(0.08)
    static let card2 = Color.white.opacity(0.06)
    static let stroke = Color.white.opacity(0.12)
    static let text = Color.white.opacity(0.92)
    static let subtext = Color.white.opacity(0.70)

    static func moodAccent(_ mood: Mood) -> Color {
        // No asset files needed; keep it simple but distinct.
        switch mood {
        case .veryLow: return Color.red.opacity(0.85)
        case .low: return Color.orange.opacity(0.85)
        case .neutral: return Color.yellow.opacity(0.85)
        case .good: return Color.green.opacity(0.85)
        case .great: return Color.cyan.opacity(0.85)
        }
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(AppTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.stroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

extension View {
    func glassCard() -> some View { self.modifier(GlassCard()) }
}
