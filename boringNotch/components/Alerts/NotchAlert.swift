//
//  NotchAlert.swift
//  boringNotch
//
//  Created by Lucas Johnston Kurilov (@lujstn) on 2026-01-22.
//

import SwiftUI

/// Style for alert action buttons
enum AlertActionStyle {
    case primary
    case secondary
}

/// An action button within a NotchAlert
struct AlertAction: Identifiable {
    let id = UUID()
    let label: String
    let style: AlertActionStyle
    let action: () -> Void
}

/// A persistent notification that requires user action
/// Blocks normal notch interaction until resolved
struct NotchAlert {
    var show: Bool = false
    var icon: String = ""
    var title: String = ""
    var message: String = ""
    var accentColor: Color = .orange
    var actions: [AlertAction] = []
    var pulseAnimation: Bool = false
}
