//
//  FileManager.swift
//  FG
//
//  Created by 윤서진 on 4/16/25.
//

class DummyFileManager {
    static let shared = DummyFileManager()
    
    let locationFileManager: LocationFileManager
    let eventLocationFileManager: EventLocationFileManager
    let coordinateFileManager: CoordinateFileManager
    let accelerationFileManager: MotionFileManager
    let groscopeFileManager: MotionFileManager
    
    private init() {
        eventLocationFileManager = EventLocationFileManager(fileName: "event_location_data")
        locationFileManager = LocationFileManager(fileName: "location_data")
        coordinateFileManager = CoordinateFileManager(fileName: "coordinate", bufferSize: 1)
        accelerationFileManager = MotionFileManager(fileName: "acceleration_data", bufferSize: 100)
        groscopeFileManager = MotionFileManager(fileName: "gyroscope_data", bufferSize: 100)
    }
}
