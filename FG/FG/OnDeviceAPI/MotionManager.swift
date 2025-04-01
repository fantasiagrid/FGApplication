//
//  MotionManager.swift
//  Location
//
//  Created by 윤서진 on 10/27/24.
//

import CoreMotion

protocol NotifableMotion {
    func receiveAccelerationData(data: CMAccelerometerData)
    func receiveGyroscopeData(data: CMGyroData)
}

class MotionManager: NSObject, ObservableObject {
    static let shared = MotionManager()
    
    public var isMonitoringAcceleration: Bool = false
    public var isMonitoringGyroscope: Bool = false
    
    private let motionManager = CMMotionManager()
    private let accelerationFileManager = MotionFileManager(fileName: "acceleration_data", bufferSize: 100)
    private let gyroscopeFileManager = MotionFileManager(fileName: "gyroscope_data", bufferSize: 100)
    
    public var notificables: [NotifableMotion] = []
    
    private override init() {
        super.init()
    }
}

// MARK: Acceleration
extension MotionManager {
    func requestOneAcceleration() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { data, error in
            guard let data = data, error == nil else {
                print("Error receiving accelerometer data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for noti in self.notificables {
                noti.receiveAccelerationData(data: data)
            }
            
            self.motionManager.stopAccelerometerUpdates()
        }
    }
    
    func startUpdatingAcceleration(frequency: Int = AcceleratorFrequency.maximum.rawValue) {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available")
            return
        }
        self.isMonitoringAcceleration = true
        self.accelerationFileManager.startMonitoring()
        
        motionManager.accelerometerUpdateInterval = TimeInterval(1 / frequency)
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { data, error in
            guard let data = data, error == nil else {
                print("Error receiving accelerometer data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for noti in self.notificables {
                noti.receiveAccelerationData(data: data)
            }
            
            self.accelerationFileManager.recordMotionData(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
        }
    }
    
    func stopUpdatingAcceleration() {
        self.isMonitoringAcceleration = false
        self.motionManager.stopAccelerometerUpdates()
        self.accelerationFileManager.stopMonitoring()
    }
}

// MARK: - Gyroscope
extension MotionManager {
    func requestOneGroscope() {
        motionManager.gyroUpdateInterval = 0.1
        motionManager.startGyroUpdates(to: OperationQueue.current!) { data, error in
            guard let data = data, error == nil else {
                print("Error receiving gyroscope data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for noti in self.notificables {
                noti.receiveGyroscopeData(data: data)
            }
            
            self.motionManager.stopGyroUpdates()
        }
    }
    
    func startUpdatingGroscope(frequency: Int = GroscopeFrequency.maximum.rawValue) {
        self.gyroscopeFileManager.startMonitoring()
        
        self.isMonitoringGyroscope = true
        motionManager.gyroUpdateInterval = TimeInterval(1 / frequency)
        motionManager.startGyroUpdates(to: OperationQueue.current!) { data, error in
            guard let data = data, error == nil else {
                print("Error receiving gyroscope data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for noti in self.notificables {
                noti.receiveGyroscopeData(data: data)
            }
            
            self.gyroscopeFileManager.recordMotionData(x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
        }
    }
    
    func stopUpdatingGyroscope() {
        self.isMonitoringGyroscope = false
        self.motionManager.stopGyroUpdates()
        self.gyroscopeFileManager.stopMonitoring()
    }
}
