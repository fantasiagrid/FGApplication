//
//  ImmersiveView.swift
//  FG
//
//  Created by 윤서진 on 2/19/25.
//

import SwiftUI
import RealityKit
import CoreMotion
import simd

struct ImmersiveView: View {
    let contentEnv: ContentEnvironment
    
    @Environment(\.openWindow) private var openWindow
    
    init(contentEnv: ContentEnvironment) {
        self.contentEnv = contentEnv
    }
    
    var body: some View {
        let xRotation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        let yRotation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(0, 1, 0))
        let finalRotation = yRotation * xRotation
        
        RealityView { content in
            DummyFileManager.shared.performance.append(date: Date(), values: ["Start entity rendering", ""])
            
            // let vrEnvironment = createPanoramicEnvironment(imageName: "360_planet")
            // content.add(vrEnvironment)
            
            for coordEntity in self.contentEnv.coordiateEntiteis {
                let x = coordEntity.coord.x
                let y = coordEntity.coord.y
                let z = coordEntity.coord.z
                
                let entity = coordEntity.entity
                entity.addTappable()
                entity.position = [Float(x), Float(y), Float(z)]
                entity.transform.scale = [0.5, 0.5, 0.5]
                entity.transform.rotation = finalRotation
                
                entity.applyFloatingAnimation(extra_y: 0.05, duration: 2)
                entity.components.set(TagComponent(tag: coordEntity.name))
                
                content.add(entity)
            }
            
            DummyFileManager.shared.performance.append(date: Date(), values: ["End entity rendering", ""])
        }.gesture(SpatialTapGesture().targetedToAnyEntity().onEnded({ value in
            var tappedEntity: Entity? = value.entity
            
            while let entity = tappedEntity {
                if let tag = entity.components[TagComponent.self] {
                    print("✅ Tapped entity with tag: \(tag.tag)")
                    self.openWindow(id: WindowID.web.rawValue, value: tag.tag)
                    return
                }
                tappedEntity = entity.parent
            }

            print("❌ Tag not found")
        }))
    }
}
