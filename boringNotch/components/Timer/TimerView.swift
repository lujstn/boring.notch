//
//  TimerView.swift
//  boringNotch
//
//  Created on 2026-01-22.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var vm: BoringViewModel
    @ObservedObject var timerVM = TimerViewModel.shared
    @ObservedObject var coordinator = BoringViewCoordinator.shared

    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 5
    @State private var selectedSeconds: Int = 0
    @State private var editingColumn: Int? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            timerContent
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            // Tap outside picker clears editing state
            if editingColumn != nil {
                editingColumn = nil
            }
        }
        // DEBUG: Green border on TimerView root
        .border(Color.green, width: 2)
        .transition(.opacity)
        .blur(radius: vm.notchState == .closed ? 30 : 0)
    }

    @ViewBuilder
    private var timerContent: some View {
        switch timerVM.timerState {
        case .idle:
            idleView
        case .running, .paused:
            TimerCountdownView()
        case .finished:
            TimerFinishedView()
        }
    }

    private var hasChanges: Bool {
        selectedHours != 0 || selectedMinutes != 5 || selectedSeconds != 0
    }

    private var canStart: Bool {
        selectedHours > 0 || selectedMinutes > 0 || selectedSeconds > 0
    }

    private var idleView: some View {
        VStack(spacing: 12) {
            TimerPickerView(
                hours: $selectedHours,
                minutes: $selectedMinutes,
                seconds: $selectedSeconds,
                editingColumn: $editingColumn
            )
            // DEBUG: Yellow border on TimerPickerView
            .border(Color.yellow, width: 1)

            HStack(spacing: 32) {
                // Reset button
                Button(action: {
                    selectedHours = 0
                    selectedMinutes = 5
                    selectedSeconds = 0
                }) {
                    Text("RESET")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundStyle(hasChanges ? .white : .gray.opacity(0.5))
                        .background(Color.gray.opacity(hasChanges ? 0.3 : 0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .disabled(!hasChanges)
                .animation(.easeOut(duration: 0.12), value: hasChanges)

                // Start button
                Button(action: {
                    timerVM.start(
                        hours: selectedHours,
                        minutes: selectedMinutes,
                        seconds: selectedSeconds
                    )
                }) {
                    Text("START")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .foregroundStyle(.white)
                        .background(Color.green.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .opacity(canStart ? 1.0 : 0.5)
                }
                .buttonStyle(.plain)
                .disabled(!canStart)
                .animation(.easeOut(duration: 0.12), value: canStart)
            }
        }
    }
}
