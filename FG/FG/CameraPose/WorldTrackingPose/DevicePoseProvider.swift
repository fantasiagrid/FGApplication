
//
//  DevicePoseProvider.swift
//  FG
//
//  Created by 윤서진 on 5/13/25.
//

import ARKit
import RealityFoundation
import simd
import QuartzCore

struct Rotation {
    let roll: Float
    let pitch: Float
    let yaw: Float
}

protocol NotifablePose {
    func receiveRotation(data: Rotation)
}

class DevicePoseProvider {
    private let session = ARKitSession()
    
    // WorldTrackingProvider can only query for the device anchor when an ImmersiveSpace is open: https://developer.apple.com/forums/thread/761167
    private let worldTracking = WorldTrackingProvider()
    private var timer: Timer?
    
    public var notificables: [NotifablePose] = []
    
    func runSession() {
        Task {
            do {
                try await session.run([worldTracking])
            } catch {
                print("\(error)")
            }
        }
    }
    
    func getDeviceTransform() -> simd_float4x4? {
        guard worldTracking.state == .running else { return nil }
        guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return nil }
        
        return deviceAnchor.originFromAnchorTransform
    }
    

    func startTracking() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard let matrix = self.getDeviceTransform() else { return }
            
            let transform = Transform(matrix: matrix)
            let rotation = transform.rotation.convertToEulerAngles()
            
            for noti in notificables {
                noti.receiveRotation(data: rotation)
            }
        }
    }

    func stopTracking() {
        timer?.invalidate()
        timer = nil
    }

    func printPrettyMatrix(_ matrix: simd_float4x4) {
        print()
        for row in 0..<4 {
            let r = matrix[row]
            print(String(format: "[% .4f, % .4f, % .4f, % .4f]", r.x, r.y, r.z, r.w))
        }
    }
}

extension simd_quatf {
    // https://stackoverflow.com/questions/78518445/visionos-detect-lateral-head-tilt
    func convertToEulerAngles() -> Rotation {
        let q = self
        let sinr_cosp = 2 * (q.real * q.imag.z + q.imag.x * q.imag.y)
        let cosr_cosp = 1 - 2 * (q.imag.z * q.imag.z + q.imag.x * q.imag.x)
        
        // 翻滚角 又叫 bank, 围绕Z轴
        var roll = atan2(sinr_cosp, cosr_cosp)
        
        let sinp = 2 * (q.real * q.imag.x - q.imag.y * q.imag.z)
        // 俯仰角 围绕X轴
        var pitch: Float
        if abs(sinp) >= 1 {
            pitch = copysign(.pi / 2, sinp)
        } else {
            pitch = asin(sinp)
        }
        
        let siny_cosp = 2 * (q.real * q.imag.y + q.imag.z * q.imag.x)
        let cosy_cosp = 1 - 2 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)

        // 偏航角 又叫 heading 围绕Y轴
        var yaw = atan2(siny_cosp, cosy_cosp)
        
        // convert to degrees
        roll = roll * 180 / .pi
        pitch = pitch * 180 / .pi
        yaw = yaw * 180 / .pi
        
        return Rotation(roll: roll, pitch: pitch, yaw: yaw)
    }
}



