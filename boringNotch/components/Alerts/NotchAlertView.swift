//
//  NotchAlertView.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-22.
//

import SwiftUI

struct NotchAlertView: View {
    @Binding var alert: NotchAlert

    @State private var isPulsing: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: alert.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(alert.accentColor)
                .opacity(alert.pulseAnimation ? (isPulsing ? 0.4 : 1.0) : 1.0)
                .animation(
                    alert.pulseAnimation
                        ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                        : .default,
                    value: isPulsing
                )

            Text(alert.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)

            Text(alert.message)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundStyle(alert.accentColor)

            Spacer()

            HStack(spacing: 6) {
                ForEach(alert.actions) { action in
                    Button(action: {
                        action.action()
                    }) {
                        Text(action.label)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .foregroundStyle(action.style == .primary ? .white : alert.accentColor)
                            .background(
                                action.style == .primary
                                    ? alert.accentColor
                                    : alert.accentColor.opacity(0.15)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 10)
        .frame(maxHeight: .infinity, alignment: .center)
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
