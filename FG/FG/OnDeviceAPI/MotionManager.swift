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
        DummyFileManager.shared.acceleration.startMonitoring(date: Date())
        
        motionManager.accelerometerUpdateInterval = TimeInterval(1 / frequency)
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { data, error in
            guard let data = data, error == nil else {
                print("Error receiving accelerometer data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for noti in self.notificables {
                noti.receiveAccelerationData(data: data)
            }
            
            DummyFileManager.shared.acceleration.append(date: Date(),
                                                                   values: ["receive",
                                                                            data.acceleration.x.description,
                                                                            data.acceleration.y.description,
                                                                            data.acceleration.z.description])
        }
    }
    
    func stopUpdatingAcceleration() {
        self.isMonitoringAcceleration = false
        self.motionManager.stopAccelerometerUpdates()
        DummyFileManager.shared.acceleration.stopMonitoring(date: Date())
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
        DummyFileManager.shared.gyroscope.startMonitoring(date: Date())
        
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
            
            DummyFileManager.shared.gyroscope.append(date: Date(),
                                                                   values: ["receive",
                                                                            data.rotationRate.x.description,
                                                                            data.rotationRate.y.description,
                                                                            data.rotationRate.z.description])
        }
    }
    
    func stopUpdatingGyroscope() {
        self.isMonitoringGyroscope = false
        self.motionManager.stopGyroUpdates()
        DummyFileManager.shared.gyroscope.stopMonitoring(date: Date())
    }
}
