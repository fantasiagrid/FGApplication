//
//  ImmersiveView.swift
//  FG
//
//  Created by 윤서진 on 2/19/25.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    let contentEnv: ContentEnvironment
    
    init(contentEnv: ContentEnvironment) {
        self.contentEnv = contentEnv
    }
    
    var body: some View {
        RealityView { content in
            for coordEntity in self.contentEnv.coordiateEntiteis {
                let x = coordEntity.coord.x
                let y = coordEntity.coord.y
                let z = coordEntity.coord.z
                coordEntity.entity.position = [Float(x), Float(y), Float(z)]
                coordEntity.entity.transform.scale = [1, 1, 1]
                
                content.add(coordEntity.entity)
            }
        }
    }
}
