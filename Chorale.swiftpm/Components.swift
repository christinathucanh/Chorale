//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import SwiftUI

struct EntryRow: View {
    let entry: MoodEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.moodAccent(entry.mood).opacity(0.25))
                    .frame(width: 44, height: 44)
                    .overlay(Circle().stroke(AppTheme.moodAccent(entry.mood).opacity(0.55), lineWidth: 1))
                Text(entry.mood.emoji).font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(entry.mood.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppTheme.text)
                    if entry.didBreathe {
                        Image(systemName: "wind")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.75))
                    }
                }
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.subtext)

                if !entry.tags.isEmpty {
                    Text(entry.tags.prefix(4).map { "#\($0)" }.joined(separator: " "))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .lineLimit(1)
                } else if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.35))
        }
        .padding(.vertical, 8)
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.white.opacity(0.55))
            TextField("Search notes, tags, mood…", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(.white)

            if !text.isEmpty {
                Button {
                    Haptics.tap()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.white.opacity(0.55))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(AppTheme.card2)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.stroke, lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

struct TagWrap: View {
    let tags: [String]

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag.hasPrefix("#") ? tag : "#\(tag)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.88))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.10))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppTheme.stroke, lineWidth: 1))
            }
        }
    }
}

/// A simple flow layout (wraps content to next line).
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        _FlowLayout(spacing: spacing, content: content)
    }
}

private struct _FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat, content: Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            self.generate(in: geo)
        }
        .frame(minHeight: 1)
    }

    private func generate(in geo: GeometryProxy) -> some View {
        var x: CGFloat = 0
        var y: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            content
                .alignmentGuide(.leading) { d in
                    if x + d.width > geo.size.width {
                        x = 0
                        y -= (d.height + spacing)
                    }
                    let result = x
                    x += d.width + spacing
                    return result
                }
                .alignmentGuide(.top) { _ in
                    let result = y
                    return result
                }
        }
    }
}
