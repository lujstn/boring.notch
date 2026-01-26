//
//  TimerCountdownView.swift
//  boringNotch
//
//  Created on 2026-01-22.
//

import SwiftUI

struct TimerCountdownView: View {
    @ObservedObject var timerVM = TimerViewModel.shared

    var body: some View {
        VStack(spacing: 10) {
            // Large countdown display
            Text(timerVM.formattedTime)
                .font(.system(size: 36, weight: .light, design: .monospaced))
                .foregroundStyle(Color.orange)

            // Control buttons
            HStack(spacing: 24) {
                // Pause/Resume button
                Button(action: {
                    if timerVM.timerState == .running {
                        timerVM.pause()
                    } else if timerVM.timerState == .paused {
                        timerVM.resume()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: timerVM.timerState == .running ? "pause.fill" : "play.fill")
                            .font(.system(size: 12))
                        Text(timerVM.timerState == .running ? "Pause" : "Resume")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)

                // Cancel button
                Button(action: {
                    timerVM.stop()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Cancel")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
