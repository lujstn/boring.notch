//
//  NotchAlertView.swift
//  boringNotch
//
//  Created on 2026-01-22.
//

import SwiftUI

struct NotchAlertView: View {
    @Binding var alert: NotchAlert

    @State private var isPulsing: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: alert.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(alert.accentColor)
                .opacity(alert.pulseAnimation ? (isPulsing ? 0.4 : 1.0) : 1.0)
                .animation(
                    alert.pulseAnimation
                        ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                        : .default,
                    value: isPulsing
                )

            // Title
            Text(alert.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)

            // Message
            Text(alert.message)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundStyle(alert.accentColor)

            Spacer()

            // Action buttons
            HStack(spacing: 8) {
                ForEach(alert.actions) { action in
                    Button(action: {
                        action.action()
                    }) {
                        Text(action.label)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundStyle(action.style == .primary ? .white : alert.accentColor)
                            .background(
                                action.style == .primary
                                    ? alert.accentColor
                                    : Color.clear
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(alert.accentColor, lineWidth: action.style == .secondary ? 1 : 0)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 36)
        .onAppear {
            if alert.pulseAnimation {
                isPulsing = true
            }
        }
        .onChange(of: alert.pulseAnimation) { _, newValue in
            isPulsing = newValue
        }
    }
}
