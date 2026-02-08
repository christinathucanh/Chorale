import SwiftUI

struct CheckInView: View {
    @EnvironmentObject private var store: MoodStore
    @State private var mood: Mood = .neutral
    @State private var tagsText: String = ""
    @State private var note: String = ""
    @State private var didBreathe: Bool = false
    @State private var showBreathing = false
    @State private var justSaved = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        Text("How are you right now?")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.text)

                        moodPicker

                        breatheToggle

                        tagsField

                        noteField

                        saveButton

                        if justSaved {
                            Text("Saved ✔︎")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.85))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.tap()
                        showBreathing = true
                    } label: {
                        Image(systemName: "wind")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Start breathing session")
                }
            }
            .sheet(isPresented: $showBreathing) {
                BreathingSessionSheet()
                    .onDisappear {
                        // Gentle prompt: if they opened the breathing, mark as didBreathe.
                        didBreathe = true
                    }
            }
        }
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.subtext)

            HStack(spacing: 10) {
                ForEach(Mood.allCases) { m in
                    Button {
                        Haptics.tap()
                        mood = m
                    } label: {
                        VStack(spacing: 6) {
                            Text(m.emoji).font(.system(size: 22))
                            Text("\(m.rawValue)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(m == mood ? AppTheme.moodAccent(m).opacity(0.25) : AppTheme.card2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(m == mood ? AppTheme.moodAccent(m).opacity(0.70) : AppTheme.stroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(mood.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.text)
        }
        .glassCard()
    }

    private var breatheToggle: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Breathing")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.text)
                Text("Mark if you did a breathing reset first.")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.subtext)
            }
            Spacer()
            Toggle("", isOn: $didBreathe)
                .labelsHidden()
        }
        .glassCard()
    }

    private var tagsField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.text)
            Text("Comma-separated (e.g. school, sleep, friends).")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.subtext)

            TextField("tags…", text: $tagsText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(AppTheme.card2)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.stroke, lineWidth: 1))
                .foregroundStyle(.white)
        }
        .glassCard()
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.text)
            Text("One sentence is enough.")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.subtext)

            TextEditor(text: $note)
                .frame(minHeight: 110)
                .padding(10)
                .background(AppTheme.card2)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.stroke, lineWidth: 1))
                .foregroundStyle(.white)
        }
        .glassCard()
    }
    

    private var saveButton: some View {
        Button {
            Haptics.success()
            let tags = tagsText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            store.add(
                MoodEntry(mood: mood, tags: tags, note: note, didBreathe: didBreathe)
            )

            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                justSaved = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    justSaved = false
                }
            }

            // reset inputs (keep mood)
            tagsText = ""
            note = ""
            didBreathe = false
        } label: {
            HStack {
                Spacer()
                Label("Save Check-In", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.vertical, 12)
                Spacer()
            }
            .foregroundStyle(.black)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}
