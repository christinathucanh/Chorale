//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct MiniTrend: View {
    let entries: [MoodEntry] // expected ascending by date

    var body: some View {
        GeometryReader { geo in
            let points = normalizedPoints(in: geo.size)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.card2)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.stroke, lineWidth: 1))

                if points.count >= 2 {
                    Path { p in
                        p.move(to: points[0])
                        for pt in points.dropFirst() {
                            p.addLine(to: pt)
                        }
                    }
                    .stroke(Color.white.opacity(0.80), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                    ForEach(points.indices, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 5, height: 5)
                            .position(points[i])
                    }
                } else if points.count == 1 {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 6, height: 6)
                        .position(points[0])
                } else {
                    EmptyView()
                }
            }
        }
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard !entries.isEmpty else { return [] }

        let w = max(1, size.width)
        let h = max(1, size.height)

        let moods = entries.map { Double($0.mood.rawValue) }
        let minMood = 1.0
        let maxMood = 5.0

        func yFor(_ mood: Double) -> CGFloat {
            // higher mood = higher on chart (smaller y)
            let t = (mood - minMood) / (maxMood - minMood)
            let y = (1.0 - t) * Double(h - 18) + 9
            return CGFloat(y)
        }

        if entries.count == 1 {
            return [CGPoint(x: w / 2, y: yFor(moods[0]))]
        }

        return entries.enumerated().map { idx, e in
            let x = (Double(idx) / Double(entries.count - 1)) * Double(w - 18) + 9
            return CGPoint(x: CGFloat(x), y: yFor(Double(e.mood.rawValue)))
        }
    }
}
