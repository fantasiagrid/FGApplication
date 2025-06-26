//
//  VirtualEnvironment.swift
//  FG
//
//  Created by 윤서진 on 6/18/25.
//

import RealityFoundation

func createPanoramicEnvironment(imageName: String) -> Entity {
    // Adapted from https://github.com/Serendipity-AI/360-image-immersive-view
    
    // Entity
    let modelEntity = Entity()
    
    // Texture
    let texture = try? TextureResource.load(named: imageName)
    guard let texture = texture else { return modelEntity }
    
    // Material
    var material = UnlitMaterial() // UnlitMaterial materials do not respond to virtual or real lighting
    material.color = .init(texture: .init(texture))
    
    // Components & Properties
    modelEntity.components.set(ModelComponent(
        mesh: .generateSphere(radius: 1E3),
        materials: [material]
    ))
    modelEntity.scale = .init(x: -10, y: 10, z: 10)
    modelEntity.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
    return modelEntity
}
