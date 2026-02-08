import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: MoodStore
    @State private var showSession = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            CheckInView()
                .tabItem { Label("Check-In", systemImage: "plus.circle.fill") }
            
            ToolkitView()
                .tabItem { Label("Toolkit", systemImage: "bandage.fill") }
            
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }
            
            InsightsView()
                .tabItem { Label("Insights", systemImage: "sparkles") }
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            
            MoodMapView()
                .tabItem { Label("Mood Map", systemImage: "calendar") }
}
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

private struct HomeView: View {
    @EnvironmentObject private var store: MoodStore
    @State private var showBreathing = false
    @State private var showMoodSound = false
    @State private var showSession = false
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        header

                        breatheCard

                        moodMusicCard

                        quickStats

                        recentPreview
                    }
                    .padding(16)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showBreathing) {
                BreathingSessionSheet()
            }
            .sheet(isPresented: $showMoodSound) {
                MoodSoundSheet()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Chorale")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.text)
            Text("A tiny ritual: breathe, name it, let it move through you.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.subtext)
        }
    }

    private var breatheCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "wind")
                    .font(.system(size: 18, weight: .semibold))
                Text("1-minute reset")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button {
                    Haptics.tap()
                    showBreathing = true
                } label: {
                    Text("Start")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Start one minute breathing")
                        .accessibilityHint("Opens the breathing guide.")

                }
            }
            Text("A simple breathing guide with a soft focus mode. Optional haptics.")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.subtext)
        }
        .glassCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Mood to Music Visualizer")
        .accessibilityHint("Opens an ambient sound and motion visualizer driven by your mood.")
        .accessibilityAddTraits(.isButton)

    }
    private var sessionCard: some View {
        
        Button {
            Haptics.tap()
            showSession = true
        } label: {
            HStack {
                Image(systemName: "sparkles")
                Text("Start guided session")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .glassCard()
        }
        .buttonStyle(.plain)
    }


    private var moodMusicCard: some View {
        Button {
            Haptics.tap()
            showMoodSound = true
        } label: {
            HStack(spacing: 12) {

                // LOGO
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )

                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                }

                // TEXT
                VStack(alignment: .leading, spacing: 3) {
                    Text("Mood → Music Visualizer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("Ambient chord + motion")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .contentShape(Rectangle())
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    private var quickStats: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick stats")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.text)

            let avg7 = store.averageMood(inLastDays: 7)
            let streak = store.currentStreak()

            HStack(spacing: 10) {
                StatPill(title: "7-day avg", value: avg7.map { String(format: "%.1f/5", $0) } ?? "—", icon: "chart.bar")
                StatPill(title: "Streak", value: "\(streak)d", icon: "flame.fill")
                StatPill(title: "Entries", value: "\(store.entries.count)", icon: "square.stack.3d.up.fill")
            }
        }
        .glassCard()
    }

    private var recentPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.text)
                Spacer()
            }

            if store.entries.isEmpty {
                Text("No entries yet. Try a check-in.")
                    .foregroundStyle(AppTheme.subtext)
                    .font(.system(size: 14))
            } else {
                ForEach(store.entries.prefix(3)) { entry in
                    EntryRow(entry: entry)
                }
            }
        }
        .glassCard()
    }
}

private struct StatPill: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12, weight: .semibold))
                Text(title).font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(AppTheme.subtext)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.card2)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.stroke, lineWidth: 1)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(title)
                .accessibilityValue(value)

        )
    }
}
