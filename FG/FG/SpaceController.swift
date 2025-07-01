//
//  SpaceController.swift
//  FG
//
//  Created by 윤서진 on 7/1/25.
//

import SwiftUI

class SpaceController {
    private var appModel: AppModel?
    private var openImmersiveSpace: OpenImmersiveSpaceAction?
    private var dismissImmersiveSpace: DismissImmersiveSpaceAction?
    
    static let shared = SpaceController()

    private init() {}
    
    func setParameters(appModel: AppModel,
                       open: OpenImmersiveSpaceAction,
                       dismiss: DismissImmersiveSpaceAction) {
        self.appModel = appModel
        self.openImmersiveSpace = open
        self.dismissImmersiveSpace = dismiss
    }
    
    func openImmersiveSpace() async {
        guard let appModel = appModel, let open = openImmersiveSpace else { return }
        if await appModel.immersiveSpaceState == .closed {
            await open(id: ImmersiveSpaceID.main.rawValue)
        }
    }
    
    func dismissImmersiveSpace() async {
        guard let appModel = appModel, let dismiss = dismissImmersiveSpace else { return }
        if await appModel.immersiveSpaceState == .open {
            await dismiss()
        }
    }
}
