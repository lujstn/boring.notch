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

    private var isNotchDisplay: Bool {
        guard let uuid = vm.screenUUID,
              let screen = NSScreen.screen(withUUID: uuid) else { return false }
        return screen.safeAreaInsets.top > 0
    }

    var body: some View {
        HStack {
            Image(systemName: "timer")
                .font(.system(size: max(13, vm.effectiveClosedNotchHeight - 19), weight: .medium))
                .foregroundStyle(.orange)
                .frame(width: 24, height: 24, alignment: .center)
                .offset(y: -1)

            Rectangle()
                .fill(.black)
                .frame(width: vm.closedNotchSize.width)

            Text(timerVM.compactTime)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.orange)
                .frame(width: 40, alignment: .trailing)
                .lineLimit(1)
                .padding(.trailing, 2)
                .offset(y: 0)
        }
        .frame(height: vm.effectiveClosedNotchHeight, alignment: .center)
        .opacity(timerVM.timerState == .paused ? 0.5 : 1.0)
    }
}
