//
//  TimerOutlineView.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-22.
//

import Defaults
import SwiftUI

/// A progress outline that traces the left, bottom, and right edges of the notch shape.
/// The path starts at the top-left, goes down, across the bottom, and up the right side.
struct TimerOutlineView: View {
    @ObservedObject var timerVM = TimerViewModel.shared
    @Default(.timerOutlineEnabled) var outlineEnabled
    @Default(.timerOutlineColor) var outlineColor

    var topCornerRadius: CGFloat
    var bottomCornerRadius: CGFloat

    private var strokeColor: Color {
        outlineColor == "white" ? .white : .orange
    }

    private var opacity: Double {
        timerVM.timerState == .paused ? 0.5 : 1.0
    }

    var body: some View {
        GeometryReader { geometry in
            TimerOutlineShape(
                topCornerRadius: topCornerRadius,
                bottomCornerRadius: bottomCornerRadius
            )
            .trim(from: 0, to: timerVM.progress)
            .stroke(
                strokeColor,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
            .opacity(opacity)
            .animation(.linear(duration: 1), value: timerVM.progress)
        }
    }
}

/// Custom shape that traces the left, bottom, and right edges of the notch.
/// Matches the geometry of NotchShape using quadratic curves for corners.
struct TimerOutlineShape: Shape {
    var topCornerRadius: CGFloat
    var bottomCornerRadius: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(topCornerRadius, bottomCornerRadius) }
        set {
            topCornerRadius = newValue.first
            bottomCornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY + topCornerRadius),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY)
        )

        path.addLine(to: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY - bottomCornerRadius))

        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius + bottomCornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY)
        )

        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius - bottomCornerRadius, y: rect.maxY))

        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY - bottomCornerRadius),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY)
        )

        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY + topCornerRadius))

        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY)
        )

        return path
    }
}

#Preview {
    VStack {
        TimerOutlineShape(topCornerRadius: 6, bottomCornerRadius: 14)
            .trim(from: 0, to: 0.5)
            .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: 200, height: 32)
            .padding(10)
            .background(Color.black)
    }
}
