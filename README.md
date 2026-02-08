# 🎶 Chorale

**Chorale** is a gentle, offline-first SwiftUI app playground that helps users pause, notice, and reflect on their emotional state through breath, sound, and minimal interaction.

Rather than tracking or analyzing emotions, Chorale treats them as something to be *listened to*. Mood is expressed through ambient music, motion, and short guided rituals designed to reduce friction during moments of stress or overwhelm.

---

## ✨ Core Features

### 🧭 Guided Session Mode
A calm, step-by-step flow that integrates:
- Mood selection
- One-minute breathing exercise
- Ambient mood-driven sound
- Optional reflection note

Sessions are intentionally short and self-contained, making them easy to complete even when attention or energy is limited.

---

### 🎵 Mood → Music Visualizer
An offline, programmatic ambient sound engine built with **AVFoundation**.
- Sound responds dynamically to selected mood
- Gentle motion and arpeggiation create a living soundscape
- No prerecorded audio or network access required

---

### 🗓️ Mood Map
A calendar-style view that visualizes mood entries over time.
- Tap any day to see details
- Optional tag-based filtering
- Designed to reveal patterns without turning emotions into metrics

---

### 📈 Trends & Insights
Lightweight, on-device trend indicators help users notice shifts over time without charts or analytics-heavy dashboards.

---

## ♿ Accessibility
Accessibility was considered throughout the design process:
- Full VoiceOver support with meaningful labels and summaries
- Respect for system settings like **Reduce Motion**
- Clear contrast, readable typography, and generous touch targets
- Visual-heavy components are summarized rather than exposed element-by-element

---

## 🔒 Privacy & Offline Use
- All data stays **on-device**
- No accounts, analytics, or network dependencies
- Safe to use in private or low-stimulation environments

---

## 🛠️ Technologies Used

- **SwiftUI** – Declarative UI, accessibility support, rapid iteration
- **AVFoundation** – Custom ambient sound synthesis and playback
- **Foundation** – Data modeling, dates, persistence
- **Haptics & Accessibility APIs** – Subtle feedback and inclusive interaction

---

## 🎯 Design Philosophy

Chorale is built around three principles:
1. **Gentleness** – Low-pressure interactions and calm pacing  
2. **Presence** – Encouraging awareness without judgment  
3. **Simplicity** – Fewer features, carefully chosen  

The app avoids gamification, streaks, or performance metrics, focusing instead on creating a space where emotions can move and settle naturally.

---

## 🚀 Running the Playground

Chorale is designed to run in **Swift Playgrounds** or Xcode using the Swift Playgrounds App template.

No additional setup or dependencies are required.

---

## 📌 Notes

This project was created as a Swift Student Challenge submission and reflects an emphasis on thoughtful interaction design, accessibility, and privacy-first development.

