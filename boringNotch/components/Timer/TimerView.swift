//
//  TimerView.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-22.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var vm: BoringViewModel
    @ObservedObject var timerVM = TimerViewModel.shared
    @ObservedObject var coordinator = BoringViewCoordinator.shared

    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0
    @State private var editingColumn: Int? = nil
    @State private var didRestoreFromPending: Bool = false

    var body: some View {
        timerContent
        .contentShape(Rectangle())
        .onTapGesture {
            if editingColumn != nil {
                editingColumn = nil
            }
        }
        .transition(.opacity)
        .blur(radius: vm.notchState == .closed ? 30 : 0)
        .onAppear {
            // Restore pending values if within 20 seconds of last change
            if timerVM.hasPendingTime && !didRestoreFromPending {
                selectedHours = timerVM.pendingHours
                selectedMinutes = timerVM.pendingMinutes
                selectedSeconds = timerVM.pendingSeconds
                didRestoreFromPending = true
            }
        }
        .onChange(of: selectedHours) { _, _ in savePendingTime() }
        .onChange(of: selectedMinutes) { _, _ in savePendingTime() }
        .onChange(of: selectedSeconds) { _, _ in savePendingTime() }
    }

    @ViewBuilder
    private var timerContent: some View {
        Group {
            switch timerVM.timerState {
            case .idle:
                idleView
                    .transition(.blurReplace)
            case .running, .paused:
                TimerCountdownView()
                    .transition(.blurReplace)
            case .finished:
                TimerFinishedView()
                    .transition(.blurReplace)
            }
        }
        .animation(.snappy(duration: 0.25), value: timerVM.timerState)
    }

    private var hasChanges: Bool {
        selectedHours != 0 || selectedMinutes != 0 || selectedSeconds != 0
    }

    private func savePendingTime() {
        timerVM.savePendingTime(hours: selectedHours, minutes: selectedMinutes, seconds: selectedSeconds)
    }

    private var canStart: Bool {
        selectedHours > 0 || selectedMinutes > 0 || selectedSeconds > 0
    }

    private var idleView: some View {
        VStack {
            VStack(spacing: 18) { // controls space between items
                TimerPickerView(
                    hours: $selectedHours,
                    minutes: $selectedMinutes,
                    seconds: $selectedSeconds,
                    editingColumn: $editingColumn
                )
                .padding(.top, 3) // controls where first item starts

                HStack(spacing: 24) {
                Button(action: {
                    editingColumn = nil
                    DispatchQueue.main.async {
                        timerVM.clearPendingTime()
                        timerVM.start(
                            hours: selectedHours,
                            minutes: selectedMinutes,
                            seconds: selectedSeconds
                        )
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                        Text("Start")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(canStart ? 0.8 : 0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!canStart)
                .animation(.easeOut(duration: 0.12), value: canStart)

                Button(action: {
                    selectedHours = 0
                    selectedMinutes = 0
                    selectedSeconds = 0
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Clear")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(.secondary)
                    .opacity(hasChanges ? 1.0 : 0.75)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!hasChanges)
                .animation(.easeOut(duration: 0.12), value: hasChanges)
                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}
