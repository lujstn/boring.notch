//
//  TimerSoundPlayer.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-26.
//

import AppKit
import Defaults

struct TimerSound: Identifiable, Hashable {
    let id: String
    let name: String
    let displayName: String
    let category: Category

    enum Category: String, CaseIterable {
        case clock = "Clock"
        case ringtones = "Ringtones"
        case alertTones = "Alert Tones"
        case systemSounds = "System Sounds"
    }

    init(id: String, name: String, category: Category, displayName: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.displayName = displayName ?? name
    }

    var path: String {
        switch category {
        case .clock:
            return "/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/Ringtones/\(name).m4r"
        case .ringtones:
            return "/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/Ringtones/\(name).m4r"
        case .alertTones:
            // Check Modern first, then Classic
            let modernPath = "/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/AlertTones/Modern/\(name).m4r"
            if FileManager.default.fileExists(atPath: modernPath) {
                return modernPath
            }
            return "/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/AlertTones/Classic/\(name).m4r"
        case .systemSounds:
            return "/System/Library/Sounds/\(name).aiff"
        }
    }
}

class TimerSoundPlayer {
    static let shared = TimerSoundPlayer()

    /// Clock sounds (EncoreInfinitum - designed for alarms/timers, loop)
    static let clockSounds: [TimerSound] = [
        ("Arpeggio-EncoreInfinitum", "Arpeggio"),
        ("Breaking-EncoreInfinitum", "Breaking"),
        ("Canopy-EncoreInfinitum", "Canopy"),
        ("Chalet-EncoreInfinitum", "Chalet"),
        ("Chirp-EncoreInfinitum", "Chirp"),
        ("Daybreak-EncoreInfinitum", "Daybreak"),
        ("Departure-EncoreInfinitum", "Departure"),
        ("Dollop-EncoreInfinitum", "Dollop"),
        ("Journey-EncoreInfinitum", "Journey"),
        ("Kettle-EncoreInfinitum", "Kettle"),
        ("Mercury-EncoreInfinitum", "Mercury"),
        ("Milky Way-EncoreInfinitum", "Milky Way"),
        ("Quad-EncoreInfinitum", "Quad"),
        ("Radial-EncoreInfinitum", "Radial"),
        ("Reflection-EncoreInfinitum", "Reflection"),
        ("Scavenger-EncoreInfinitum", "Scavenger"),
        ("Seedling-EncoreInfinitum", "Seedling"),
        ("Shelter-EncoreInfinitum", "Shelter"),
        ("Sprinkles-EncoreInfinitum", "Sprinkles"),
        ("Steps-EncoreInfinitum", "Steps"),
        ("Storytime-EncoreInfinitum", "Storytime"),
        ("Tease-EncoreInfinitum", "Tease"),
        ("Tilt-EncoreInfinitum", "Tilt"),
        ("Unfold-EncoreInfinitum", "Unfold"),
        ("Valley-EncoreInfinitum", "Valley")
    ].map { TimerSound(id: "clock_\($0.1)", name: $0.0, category: .clock, displayName: $0.1) }

    /// Available ringtones (longer, can loop)
    static let ringtones: [TimerSound] = [
        "Alarm", "Apex", "Beacon", "Bulletin", "Chimes",
        "Circuit", "Constellation", "Cosmic", "Crystals",
        "Hillside", "Illuminate", "Night Owl", "Opening",
        "Playtime", "Presto", "Radar", "Radiate", "Ripples",
        "Sencha", "Signal", "Silk", "Slow Rise", "Stargaze",
        "Summit", "Twinkle", "Uplift", "Waves"
    ].map { TimerSound(id: "ringtone_\($0)", name: $0, category: .ringtones) }

    /// Available alert tones (shorter, one-shot)
    static let alertTones: [TimerSound] = [
        // Modern
        "Aurora", "Bamboo", "Chord", "Circles", "Complete",
        "Hello", "Input", "Keys", "Note", "Popcorn", "Pulse", "Synth",
        // Classic
        "Anticipate", "Bell", "Bloom", "Calypso", "Chime",
        "Descent", "Ding", "Electronic", "Fanfare", "Glass",
        "Horn", "Ladder", "Minuet", "Noir", "Spell",
        "Suspense", "Swoosh", "Telegraph", "Tri-Tone", "Update"
    ].map { TimerSound(id: "alert_\($0)", name: $0, category: .alertTones) }

    /// System sounds (beeps)
    static let systemSounds: [TimerSound] = [
        "Basso", "Blow", "Bottle", "Frog", "Funk",
        "Glass", "Hero", "Morse", "Ping", "Pop",
        "Purr", "Sosumi", "Submarine", "Tink"
    ].map { TimerSound(id: "system_\($0)", name: $0, category: .systemSounds) }

    /// All sounds grouped by category
    static var allSounds: [TimerSound] {
        clockSounds + ringtones + alertTones + systemSounds
    }

    /// Find a sound by its ID
    static func sound(forId id: String) -> TimerSound? {
        allSounds.first { $0.id == id }
    }

    private var currentSound: NSSound?
    private var isLooping: Bool = false

    private init() {}

    /// Play the configured timer sound
    func playTimerSound() {
        let soundId = Defaults[.timerSoundName]
        let volume = Defaults[.timerSoundVolume]

        guard let sound = Self.sound(forId: soundId) else {
            // Fallback to system beep
            NSSound.beep()
            return
        }

        // Clock and Ringtones loop, alert tones don't
        let shouldLoop = sound.category == .clock || sound.category == .ringtones
        play(sound: sound, volume: Float(volume), loop: shouldLoop)
    }

    /// Play a specific sound
    func play(sound: TimerSound, volume: Float, loop: Bool = false) {
        stop()

        let url = URL(fileURLWithPath: sound.path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            NSSound.beep()
            return
        }

        currentSound = NSSound(contentsOf: url, byReference: false)
        currentSound?.volume = volume
        currentSound?.loops = loop
        isLooping = loop
        currentSound?.play()
    }

    /// Preview a sound at the configured volume (no loop for preview)
    func preview(soundId: String) {
        guard let sound = Self.sound(forId: soundId) else { return }
        let volume = Defaults[.timerSoundVolume]
        play(sound: sound, volume: Float(volume), loop: false)
    }

    /// Stop any playing sound
    func stop() {
        currentSound?.stop()
        currentSound = nil
        isLooping = false
    }
}
