//
//  AppModel.swift
//  FG
//
//  Created by 윤서진 on 2/19/25.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    enum ImmersiveSpaceState {
        case closed
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}

enum WindowID: String {
    case web = "Web"
}

enum ImmersiveSpaceID: String {
    case main = "ImmersiveSpace"
}
