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
            /*
            if let appleEntity = try? await Entity(named: "Character", in: realityKitContentBundle) {
                content.add(appleEntity)
                appleEntity.position = [0, 0, -3]
                appleEntity.transform.scale = [10, 10, 10]
            }*/
            
            coordinateMapper.initRotationMatrix()
        
            // 37.555503, 127.047632 운동장
            // 37.560348, 127.040708
            // 37.556955, 127.047640 한양 사이버대
            // 37.565898, 127.055460 투썸
            let obj_coord = GeographicCoordinate(date: Date(), latitude: 37.565898, longitude: 127.055460, altitude: 0)
            let obj_pos = coordinateMapper.calcObjectPosition(objGeographicData: obj_coord)
            if let appleEntity = try? await Entity(named: "Character", in: realityKitContentBundle) {
                content.add(appleEntity)
                
                appleEntity.position = [Float(obj_pos!.x), Float(obj_pos!.y), Float(obj_pos!.z)]
                appleEntity.transform.scale = [10, 10, 10]
            }
            
            DummyFileManager.shared.coordinateFileManager.recordData(x: obj_pos!.x, y: obj_pos!.y, z: obj_pos!.z)
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}

