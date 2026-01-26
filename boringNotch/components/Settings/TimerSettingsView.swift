//
//  TimerSettingsView.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-22.
//

import Defaults
import SwiftUI

struct TimerSettingsView: View {
    @Default(.timerSoundEnabled) var soundEnabled
    @Default(.timerSoundName) var soundName
    @Default(.timerSoundVolume) var soundVolume
    @Default(.timerSnoozeEnabled) var snoozeEnabled
    @Default(.timerSnoozeIntervals) var snoozeIntervals
    @Default(.timerOutlineEnabled) var outlineEnabled
    @Default(.timerOutlineColor) var outlineColor
    @Default(.timerShowInCollapsed) var showInCollapsed

    @State private var isPreviewPlaying: Bool = false

    var body: some View {
        Form {
            Section {
                Defaults.Toggle(key: .timerEnabled) {
                    Text("Enable timer")
                }
            }

            Section {
                Defaults.Toggle(key: .timerSoundEnabled) {
                    Text("Play sound when timer ends")
                }

                if soundEnabled {
                    HStack {
                        Picker("Sound", selection: $soundName) {
                            Section("Clock") {
                                ForEach(TimerSoundPlayer.clockSounds) { sound in
                                    Text(sound.displayName).tag(sound.id)
                                }
                            }
                            Section("Ringtones") {
                                ForEach(TimerSoundPlayer.ringtones) { sound in
                                    Text(sound.displayName).tag(sound.id)
                                }
                            }
                            Section("Alert Tones") {
                                ForEach(TimerSoundPlayer.alertTones) { sound in
                                    Text(sound.displayName).tag(sound.id)
                                }
                            }
                            Section("System Sounds") {
                                ForEach(TimerSoundPlayer.systemSounds) { sound in
                                    Text(sound.displayName).tag(sound.id)
                                }
                            }
                        }

                        Button(action: {
                            if isPreviewPlaying {
                                TimerSoundPlayer.shared.stop()
                                isPreviewPlaying = false
                            } else {
                                TimerSoundPlayer.shared.preview(soundId: soundName)
                                isPreviewPlaying = true
                            }
                        }) {
                            Image(systemName: isPreviewPlaying ? "stop.fill" : "speaker.wave.2.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help(isPreviewPlaying ? "Stop preview" : "Preview sound")
                    }

                    HStack {
                        Text("Volume")
                        Slider(value: $soundVolume, in: 0.1...1.0, step: 0.1)
                        Text("\(Int(soundVolume * 100))%")
                            .foregroundStyle(.secondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            } header: {
                Text("Sound")
            }

            Section {
                Defaults.Toggle(key: .timerSnoozeEnabled) {
                    Text("Enable snooze options")
                }

                if snoozeEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Snooze intervals shown in alert")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            ForEach([5, 10, 15], id: \.self) { interval in
                                Toggle(isOn: Binding(
                                    get: { snoozeIntervals.contains(interval) },
                                    set: { isSelected in
                                        if isSelected {
                                            if !snoozeIntervals.contains(interval) {
                                                snoozeIntervals.append(interval)
                                                snoozeIntervals.sort()
                                            }
                                        } else {
                                            // Ensure at least one interval remains selected
                                            if snoozeIntervals.count > 1 {
                                                snoozeIntervals.removeAll { $0 == interval }
                                            }
                                        }
                                    }
                                )) {
                                    Text("\(interval) min")
                                }
                                .toggleStyle(.checkbox)
                            }
                        }
                    }
                }
            } header: {
                Text("Snooze")
            }

            Section {
                Defaults.Toggle(key: .timerShowInCollapsed) {
                    Text("Show timer in collapsed notch")
                }

                Defaults.Toggle(key: .timerOutlineEnabled) {
                    Text("Show progress outline around notch")
                }

                if outlineEnabled {
                    Picker("Outline color", selection: $outlineColor) {
                        Text("Orange").tag("orange")
                        Text("White").tag("white")
                    }
                }
            } header: {
                Text("Appearance")
            }
        }
        .accentColor(.effectiveAccent)
        .navigationTitle("Timer")
        .onChange(of: soundName) { _, _ in
            // Stop preview when sound selection changes
            TimerSoundPlayer.shared.stop()
            isPreviewPlaying = false
        }
        .onDisappear {
            // Stop preview when leaving settings
            TimerSoundPlayer.shared.stop()
            isPreviewPlaying = false
        }
        .onAppear {
            // Validate sound selection - reset to default if invalid
            if TimerSoundPlayer.sound(forId: soundName) == nil {
                soundName = "clock_Radial"
            }
        }
    }
}

#Preview {
    TimerSettingsView()
}
