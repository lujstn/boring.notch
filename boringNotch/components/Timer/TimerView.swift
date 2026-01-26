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
    @State private var selectedMinutes: Int = 5
    @State private var selectedSeconds: Int = 0
    @State private var editingColumn: Int? = nil
    @State private var didRestoreFromPending: Bool = false

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
        .background(GeometryReader { geo in
            Color.clear.onAppear {
                print("[DEBUG TimerView] size: \(geo.size), frame: \(geo.frame(in: .global))")
            }.onChange(of: geo.size) { old, new in
                print("[DEBUG TimerView] size changed: \(old) -> \(new)")
            }
        })
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
        selectedHours != 0 || selectedMinutes != 5 || selectedSeconds != 0
    }

    private func savePendingTime() {
        timerVM.savePendingTime(hours: selectedHours, minutes: selectedMinutes, seconds: selectedSeconds)
    }

    private var canStart: Bool {
        selectedHours > 0 || selectedMinutes > 0 || selectedSeconds > 0
    }

    private var idleView: some View {
        VStack(spacing: 9) {
            TimerPickerView(
                hours: $selectedHours,
                minutes: $selectedMinutes,
                seconds: $selectedSeconds,
                editingColumn: $editingColumn
            )
            .background(GeometryReader { geo in
                Color.clear.onAppear { print("[DEBUG] TimerPickerView height: \(geo.size.height)") }
            })

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
                    timerVM.clearPendingTime()
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
            .background(GeometryReader { geo in
                Color.clear.onAppear { print("[DEBUG] Button row height: \(geo.size.height)") }
            })
        }
        .background(GeometryReader { geo in
            Color.clear.onAppear { print("[DEBUG] idleView total height: \(geo.size.height)") }
        })
    }
}
