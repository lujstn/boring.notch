//
//  TimerCountdownView.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-22.
//

import SwiftUI

struct TimerCountdownView: View {
    @ObservedObject var timerVM = TimerViewModel.shared

    var body: some View {
        VStack(spacing: 0) {
            Text(timerVM.formattedTime)
                .font(.system(size: 36, weight: .light, design: .monospaced))
                .foregroundStyle(Color.orange)
                .frame(maxWidth: .infinity)

            HStack(spacing: timerVM.timerState == .paused ? 6 : -4) {
                    // Play/Pause - always present, icon animates in place
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
                        .id(timerVM.timerState)
                        .frame(width: 70, alignment: .leading)
                        .foregroundStyle(.white)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 14) {
                        // Reset - always visible, dimmed when not paused
                        Button(action: {
                            timerVM.reset()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Reset")
                                    .font(.system(size: 13))
                            }
                            .foregroundStyle(.secondary)
                            .opacity(timerVM.timerState == .paused ? 1.0 : 0.5)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(timerVM.timerState != .paused)

                        // Cancel - always present
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .animation(.snappy(duration: 0.25), value: timerVM.timerState)
                .padding(.top, 10)
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
