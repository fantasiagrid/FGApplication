//
//  DevicePoseProvider.swift
//  FG
//
//  Created by 윤서진 on 4/13/25.
//

import ARKit

@Observable class DevicePoseProvider {
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()

    func runSession() async {
        try? await session.run([worldTracking])
    }

    func getDeviceTransform() async -> simd_float4x4? {
        guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: 0) else { return nil }
        return deviceAnchor.originFromAnchorTransform
    }
}
