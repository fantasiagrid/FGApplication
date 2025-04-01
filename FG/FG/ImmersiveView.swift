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
    let visionPro = VisionPro()
    
    var body: some View {
        RealityView { content in
            // Add entity
            if let appleEntity = try? await Entity(named: "Character", in: realityKitContentBundle) {
                content.add(appleEntity)
                appleEntity.position = [0, 0, -3]
            }
            
            // Pose
            _ = content.subscribe(to: SceneEvents.Update.self) { _ in
                Task {
                    let mat = await visionPro.transformMatrix()
                    let x = await visionPro.transformMatrix().columns.3.x
                    let y = await visionPro.transformMatrix().columns.3.y
                    let z = await visionPro.transformMatrix().columns.3.z
                    print(String(format: "%.2f, %.2f, %.2f", x, y, z))
                }
            }
        }.task {
            await visionPro.runArkitSession()
        }
    }
}

import ARKit
@Observable class VisionPro {
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    
    func transformMatrix() async -> simd_float4x4 {
        guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: .zero)
        else { return .init() }
        return deviceAnchor.originFromAnchorTransform
    }
    
    func runArkitSession() async {
        Task {
            try? await session.run([worldTracking])
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}

