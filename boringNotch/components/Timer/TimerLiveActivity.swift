//
//  TimerLiveActivity.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-22.
//

import SwiftUI

struct TimerLiveActivity: View {
    @EnvironmentObject var vm: BoringViewModel
    @ObservedObject var timerVM = TimerViewModel.shared

    var body: some View {
        HStack {
            // Left: Timer icon - minimum 16pt font
            Image(systemName: "timer")
                .font(.system(size: max(16, vm.effectiveClosedNotchHeight - 16), weight: .medium))
                .foregroundStyle(.orange)
                .frame(width: 24, height: 24, alignment: .center)

            // Center: Black rectangle spacer
            Rectangle()
                .fill(.black)
                .frame(width: vm.closedNotchSize.width)

            // Right: Remaining time - fixed width for text
            Text(timerVM.compactTime)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(.orange)
                .frame(width: 40, alignment: .trailing)
                .lineLimit(1)
                .padding(.trailing, 2)
        }
        .frame(height: vm.effectiveClosedNotchHeight + 2, alignment: .center)
        .opacity(timerVM.timerState == .paused ? 0.5 : 1.0)
    }
}
