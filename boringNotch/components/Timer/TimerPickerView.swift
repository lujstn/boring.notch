//
//  TimerPickerView.swift
//  boringNotch
//
//  Created on 2026-01-22.
//

import SwiftUI
import AppKit

struct TimerPickerColumn: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String
    let columnIndex: Int
    var editingColumn: Binding<Int?>

    @State private var isHovering: Bool = false
    @State private var upPressed: Bool = false
    @State private var downPressed: Bool = false
    @State private var inputBuffer: String = ""
    @State private var cursorVisible: Bool = true
    @State private var cursorTimer: Timer?

    private let hoverWidth: CGFloat = 48

    private var isEditing: Bool {
        editingColumn.wrappedValue == columnIndex
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // Top hit area (increment)
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .frame(width: hoverWidth, height: 32)
                    .overlay(alignment: .bottom) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(upPressed ? .white : .secondary)
                            .padding(.bottom, 4)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in upPressed = true }
                            .onEnded { _ in
                                upPressed = false
                                if value < range.upperBound { value += 1 }
                            }
                    )

                // Digit display - shows cursor when editing
                Group {
                    if isEditing {
                        Text(inputBuffer.isEmpty ? "|" : inputBuffer)
                            .opacity(inputBuffer.isEmpty ? (cursorVisible ? 1 : 0) : 1)
                    } else {
                        Text(String(format: "%02d", value))
                    }
                }
                .font(.system(size: 24, weight: .light, design: .monospaced))
                .foregroundStyle(isHovering || isEditing ? .white : .secondary)
                .frame(width: 40, height: 30)
                .contentShape(Rectangle())
                .onTapGesture {
                    startEditing()
                }
                .animation(.easeOut(duration: 0.1), value: isEditing)
                .animation(.easeOut(duration: 0.1), value: value)

                // Bottom hit area (decrement)
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .frame(width: hoverWidth, height: 32)
                    .overlay(alignment: .top) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(downPressed ? .white : .secondary)
                            .padding(.top, 4)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in downPressed = true }
                            .onEnded { _ in
                                downPressed = false
                                if value > range.lowerBound { value -= 1 }
                            }
                    )
            }
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.1)) {
                    isHovering = hovering
                }
            }
            .background(
                KeyboardInputView(
                    isActive: isEditing,
                    onCharacter: handleCharacter,
                    onEnter: commitValue,
                    onEscape: cancelEditing
                )
            )

            // Label (outside hover zone)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                startCursorBlink()
            } else {
                stopCursorBlink()
            }
        }
    }

    private func startEditing() {
        editingColumn.wrappedValue = columnIndex
        inputBuffer = ""
        cursorVisible = true
    }

    private func handleCharacter(_ char: Character) {
        guard char.isNumber, inputBuffer.count < 2 else { return }
        inputBuffer.append(char)

        // Auto-commit after 2 digits
        if inputBuffer.count == 2 {
            commitValue()
        }
    }

    private func commitValue() {
        if let newValue = Int(inputBuffer) {
            // Clamp to range
            value = min(max(newValue, range.lowerBound), range.upperBound)
        }
        editingColumn.wrappedValue = nil
        inputBuffer = ""
    }

    private func cancelEditing() {
        editingColumn.wrappedValue = nil
        inputBuffer = ""
    }

    private func startCursorBlink() {
        cursorVisible = true
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            cursorVisible.toggle()
        }
    }

    private func stopCursorBlink() {
        cursorTimer?.invalidate()
        cursorTimer = nil
    }
}

// Helper view to capture keyboard input via NSEvent monitor
struct KeyboardInputView: NSViewRepresentable {
    let isActive: Bool
    let onCharacter: (Character) -> Void
    let onEnter: () -> Void
    let onEscape: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyboardCaptureNSView()
        view.onCharacter = onCharacter
        view.onEnter = onEnter
        view.onEscape = onEscape
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let view = nsView as? KeyboardCaptureNSView else { return }
        view.isActiveForInput = isActive
        view.onCharacter = onCharacter
        view.onEnter = onEnter
        view.onEscape = onEscape
    }
}

class KeyboardCaptureNSView: NSView {
    var isActiveForInput: Bool = false
    var onCharacter: ((Character) -> Void)?
    var onEnter: (() -> Void)?
    var onEscape: (() -> Void)?

    private var eventMonitor: Any?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        setupEventMonitor()
    }

    private func setupEventMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, self.isActiveForInput else { return event }

            if event.keyCode == 36 { // Enter
                self.onEnter?()
                return nil
            } else if event.keyCode == 53 { // Escape
                self.onEscape?()
                return nil
            } else if let chars = event.characters, let char = chars.first, char.isNumber {
                self.onCharacter?(char)
                return nil
            }

            return event
        }
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

struct TimerPickerView: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    @Binding var editingColumn: Int?

    var body: some View {
        HStack(spacing: 4) {
            TimerPickerColumn(value: $hours, range: 0...23, label: "hours",
                              columnIndex: 0, editingColumn: $editingColumn)

            Text(":")
                .font(.system(size: 24, weight: .light, design: .monospaced))
                .foregroundStyle(.tertiary)
                .offset(y: -6)

            TimerPickerColumn(value: $minutes, range: 0...59, label: "min",
                              columnIndex: 1, editingColumn: $editingColumn)

            Text(":")
                .font(.system(size: 24, weight: .light, design: .monospaced))
                .foregroundStyle(.tertiary)
                .offset(y: -6)

            TimerPickerColumn(value: $seconds, range: 0...59, label: "sec",
                              columnIndex: 2, editingColumn: $editingColumn)
        }
    }
}
