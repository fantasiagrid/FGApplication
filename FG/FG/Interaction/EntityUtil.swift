//
//  ModelEntityUtil.swift
//  FG
//
//  Created by 윤서진 on 6/25/25.
//

import Foundation
import RealityKit

extension Entity {
    func addTappable() {
        self.components.set(InputTargetComponent())
        self.generateCollisionShapes(recursive: true)
    }
}
