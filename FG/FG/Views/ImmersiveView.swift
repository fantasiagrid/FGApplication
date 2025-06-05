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
    
    init(contentEnv: ContentEnvironment) {
        self.contentEnv = contentEnv
    }
    
    var body: some View {
        let xRotation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        let yRotation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(0, 1, 0))
        let finalRotation = yRotation * xRotation
        
        RealityView { content in
            DummyFileManager.shared.performance.append(date: Date(), values: ["Start entity rendering", ""])
            
            var i = 0
            for coordEntity in self.contentEnv.coordiateEntiteis {
                let x = coordEntity.coord.x
                let y = coordEntity.coord.y
                let z = coordEntity.coord.z
                
                let entity = coordEntity.entity
                entity.position = [Float(x), Float(y), Float(z)]
                entity.transform.scale = [0.5, 0.5, 0.5]
                entity.transform.rotation = finalRotation
                
                // Lightening
                if i == 0 {
                    let lightEntity = ModelEntity(mesh: .generateSphere(radius: 0.1))
                    lightEntity.position = [Float(x), 1, -1]
                    
                    let material = SimpleMaterial(color: .red, isMetallic: false)
                    lightEntity.model?.materials = [material]
                    
                    lightEntity.components.set(SpotLightComponent(color: .red,
                                                                  intensity: 10_000,
                                                                  innerAngleInDegrees: 0,
                                                                  outerAngleInDegrees: 45,
                                                                  attenuationRadius: 6,
                                                                  ))
                    content.add(lightEntity)
                } else if i == 1 {
                    let lightEntity = ModelEntity(mesh: .generateSphere(radius: 0.1))
                    lightEntity.position = [Float(x), 1, -1]
                    
                    let material = SimpleMaterial(color: .blue, isMetallic: false)
                    lightEntity.model?.materials = [material]
                    
                    lightEntity.components.set(PointLightComponent(color: .blue,
                                                                   intensity: 10_000,
                                                                   attenuationRadius: 6))
                    content.add(lightEntity)
                    
                } else {
                    let lightEntity = ModelEntity(mesh: .generateSphere(radius: 0.1))
                    lightEntity.position = [Float(x), 1, -1]
                    
                    let material = SimpleMaterial(color: .white, isMetallic: false)
                    lightEntity.model?.materials = [material]
                    
                    lightEntity.components.set(DirectionalLightComponent(color: .white, intensity: 10_000))
                    content.add(lightEntity)
                }
                
                entity.applyFloatingAnimation(extra_y: 0.05, duration: 2)
                
                content.add(entity)
                
                i += 1
            }
            
            DummyFileManager.shared.performance.append(date: Date(), values: ["End entity rendering", ""])
        }
    }
}
