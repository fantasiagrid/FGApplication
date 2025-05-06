//
//  ImmersiveView.swift
//  FG
//
//  Created by 윤서진 on 2/19/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import simd

struct ImmersiveView: View {
    let coordinateMapper = CoordinateMapper.shared
    
    var body: some View {
        RealityView { content in
            coordinateMapper.initRotationMatrix()
        
            let obj_coord = GeographicCoordinate(date: Date(),
                                                 latitude: BuildScheme.testPoseCoordinates.objCoord.latitude,
                                                 longitude: BuildScheme.testPoseCoordinates.objCoord.longitude,
                                                 altitude: BuildScheme.testPoseCoordinates.objCoord.altitude)
            let obj_pos = coordinateMapper.calcObjectPosition(objGeographicData: obj_coord)
            /*
            if let appleEntity = try? await Entity(named: "Character", in: realityKitContentBundle) {
                content.add(appleEntity)
                
                appleEntity.position = [Float(obj_pos!.x), Float(obj_pos!.y), Float(obj_pos!.z)]
                appleEntity.transform.scale = [10, 10, 10]
            }
             */
            // DummyFileManager.shared.coordinateFileManager.recordData(x: obj_pos!.x, y: obj_pos!.y, z: obj_pos!.z)
            
            /*
            if let entity = try? await Entity(named: "house") {
                content.add(entity)
                
                entity.position = [0, 0, -1]
            }
            
            if let entity = try? await Entity(named: "blue_cat") {
                content.add(entity)
                
                entity.position = [1, 0, -1]
            }
             */
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}

