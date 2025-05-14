//
//  RenterUtil.swift
//  FG
//
//  Created by 윤서진 on 5/10/25.
//

import Foundation
import RealityFoundation

func loadEntity(from url: URL) async throws -> Entity {
    let entity = try await Entity(contentsOf: url)
    
    return entity
}

func findModelEntity(in entity: Entity) -> ModelEntity? {
    if let model = entity as? ModelEntity {
        return model
    }
    for child in entity.children {
        if let found = findModelEntity(in: child) {
            return found
        }
    }
    return nil
}

func uniqueVertexCount(from modelEntity: ModelEntity) -> Int {
    var uniquePositions = Set<SIMD3<Float>>()

    for meshModel in modelEntity.model?.mesh.contents.models ?? [] {
        for part in meshModel.parts {
            for position in part.positions.elements {
                uniquePositions.insert(position)
            }
        }
    }

    return uniquePositions.count
}
