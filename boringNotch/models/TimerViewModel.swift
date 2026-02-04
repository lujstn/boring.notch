//
//  TimerViewModel.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-22.
//

import Combine
import Defaults
import SwiftUI

extension Notification.Name {
    static let timerFinished = Notification.Name("timerFinished")
}

@MainActor
class TimerViewModel: ObservableObject {
    static let shared = TimerViewModel()

    @Published var timerState: TimerState = .idle
    @Published var totalSeconds: Int = 0
    @Published var remainingSeconds: Int = 0

    // Picker state persistence (survives view recreation for 20 seconds)
    private(set) var pendingHours: Int = 0
    private(set) var pendingMinutes: Int = 5
    private(set) var pendingSeconds: Int = 0
    private var pendingLastModified: Date?
    private let pendingExpirationSeconds: TimeInterval = 20

    private var timerCancellable: AnyCancellable?

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    var formattedTime: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return "\(seconds)s"
        }
    }

    var compactTime: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }

    private init() {}

    // MARK: - Picker State Persistence

    /// Save picker values when user makes changes
    func savePendingTime(hours: Int, minutes: Int, seconds: Int) {
        pendingHours = hours
        pendingMinutes = minutes
        pendingSeconds = seconds
        pendingLastModified = Date()
    }

    /// Check if pending values are still valid (within 20 seconds)
    var hasPendingTime: Bool {
        guard let lastModified = pendingLastModified else { return false }
        return Date().timeIntervalSince(lastModified) < pendingExpirationSeconds
    }

    /// Clear pending state (e.g., after starting timer)
    func clearPendingTime() {
        pendingLastModified = nil
    }

    func start(hours: Int, minutes: Int, seconds: Int) {
        let total = hours * 3600 + minutes * 60 + seconds
        guard total > 0 else { return }

        totalSeconds = total
        remainingSeconds = total
        timerState = .running
        startTimer()
    }

    func pause() {
        guard timerState == .running else { return }
        timerCancellable?.cancel()
        timerState = .paused
    }

    func resume() {
        guard timerState == .paused else { return }
        timerState = .running
        startTimer()
    }

    func reset() {
        guard timerState == .paused else { return }
        remainingSeconds = totalSeconds
    }

    func stop() {
        timerCancellable?.cancel()
        TimerSoundPlayer.shared.stop()
        BoringViewCoordinator.shared.dismissAlert()
        timerState = .idle
        totalSeconds = 0
        remainingSeconds = 0
    }

    func snooze(minutes: Int) {
        guard timerState == .finished else { return }
        TimerSoundPlayer.shared.stop()
        BoringViewCoordinator.shared.dismissAlert()
        let additional = minutes * 60
        totalSeconds += additional
        remainingSeconds = additional
        timerState = .running
        startTimer()
    }

    func dismiss() {
        timerCancellable?.cancel()
        TimerSoundPlayer.shared.stop()
        BoringViewCoordinator.shared.dismissAlert()
        timerState = .idle
        totalSeconds = 0
        remainingSeconds = 0
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.timerCancellable?.cancel()
                    self.timerState = .finished
                    self.playCompletionSound()
                    self.expandNotch()
                }
            }
    }

    private func playCompletionSound() {
        guard Defaults[.timerSoundEnabled] else { return }
        TimerSoundPlayer.shared.playTimerSound()
    }

    private func expandNotch() {
        showTimerFinishedAlert()
    }

    private func showTimerFinishedAlert() {
        let coordinator = BoringViewCoordinator.shared
        coordinator.showAlert(NotchAlert(
            show: true,
            icon: "timer",
            title: "Timer",
            message: "00:00:00",
            accentColor: .orange,
            actions: [
                AlertAction(label: "+5m", style: .secondary) { [weak self] in
                    self?.snooze(minutes: 5)
                },
                AlertAction(label: "+10m", style: .secondary) { [weak self] in
                    self?.snooze(minutes: 10)
                },
                AlertAction(label: "Dismiss", style: .primary) { [weak self] in
                    self?.dismiss()
                }
            ],
            pulseAnimation: true
        ))
    }
}
