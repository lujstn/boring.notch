//
//  TimerFinishedView.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-22.
//

import Defaults
import SwiftUI

struct TimerFinishedView: View {
    @ObservedObject var timerVM = TimerViewModel.shared
    @Default(.timerSnoozeEnabled) var snoozeEnabled
    @Default(.timerSnoozeIntervals) var snoozeIntervals

    @State private var pulsingOpacity: Double = 0.4

    var body: some View {
        VStack(spacing: 10) {
            // Pulsing 00:00:00 display
            Text("00:00:00")
                .font(.system(size: 36, weight: .light, design: .monospaced))
                .foregroundStyle(Color.orange)
                .opacity(pulsingOpacity)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulsingOpacity)
                .onAppear {
                    pulsingOpacity = 1.0
                }

            // Action buttons
            HStack(spacing: 12) {
                // Dismiss button
                Button(action: {
                    timerVM.dismiss()
                }) {
                    Text("Dismiss")
                        .font(.system(size: 12))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                // Snooze buttons
                if snoozeEnabled {
                    ForEach(snoozeIntervals, id: \.self) { interval in
                        Button(action: {
                            timerVM.snooze(minutes: interval)
                        }) {
                            Text("+\(interval)m")
                                .font(.system(size: 12))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.3))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
