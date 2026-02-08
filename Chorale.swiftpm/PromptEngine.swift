//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation

enum PromptEngine {
    static func prompts(for mood: Mood) -> [String] {
        switch mood {
        case .veryLow:
            return [
                "What feels heaviest right now?",
                "What do you need most in this moment?",
                "What would make this 1% easier?"
            ]
        case .low:
            return [
                "What triggered this feeling?",
                "What helped even a little?",
                "What’s one small thing you can do next?"
            ]
        case .neutral:
            return [
                "What’s been taking up mental space?",
                "What are you noticing right now?",
                "What direction are you drifting today?"
            ]
        case .good:
            return [
                "What went right today?",
                "What contributed to this mood?",
                "How can you repeat this tomorrow?"
            ]
        case .great:
            return [
                "What made today feel meaningful?",
                "What strengths showed up?",
                "Who or what are you grateful for?"
            ]
        }
    }
}
