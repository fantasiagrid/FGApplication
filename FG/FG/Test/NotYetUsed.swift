//
//  abc.swift
//  FG
//
//  Created by 윤서진 on 3/31/25.
//

// https://stackoverflow.com/questions/78050686/realitykit-track-head-movement-position
/*
_ = content.subscribe(to: SceneEvents.Update.self) { _ in
    Task {
        let x = await visionPro.transformMatrix().columns.3.x
        let y = await visionPro.transformMatrix().columns.3.y
        let z = await visionPro.transformMatrix().columns.3.z
        print(String(format: "%.2f, %.2f, %.2f", x, y, z))
    }
}
*/



/*
let rotationMatrix: simd_float3x3 = simd_float3x3([
    simd_float3(1, 0, 0),
    simd_float3(0, 1, 0),
    simd_float3(0, 0, 1)
])

// TODO: Global rotation을 적용할 수 있어야함
let rotationQuaternion = simd_quatf(rotationMatrix)

// Apply the quaternion to the entity's orientation
appleEntity.orientation = rotationQuaternion
*/

