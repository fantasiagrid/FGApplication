//
//  FileManager.swift
//  FG
//
//  Created by 윤서진 on 4/16/25.
//

class DummyFileManager {
    static let shared = DummyFileManager()
    
    let location: BaseCSVFileManager
    let eventLocation: BaseCSVFileManager
    let coordinate: BaseCSVFileManager
    let acceleration: BaseCSVFileManager
    let gyroscope: BaseCSVFileManager
    let fps: BaseCSVFileManager
    
    private init() {
        location = BaseCSVFileManager(fileName: "location",
                                      bufferSize: 10,
                                      headerFields: ["Time", "EventType", "Latitude", "Longitude"])
        
        eventLocation = BaseCSVFileManager(fileName: "event_location",
                                           bufferSize: 1,
                                           headerFields: ["Time", "EventType", "Latitude", "Longitude"])
            
        coordinate = BaseCSVFileManager(fileName: "coordinate",
                                        bufferSize: 1,
                                        headerFields: ["Time", "EventType", "x", "y", "z"])

        acceleration = BaseCSVFileManager(fileName: "acceleration",
                                          bufferSize: 100,
                                          headerFields: ["Time", "EventType", "x", "y", "z"])
        
        gyroscope = BaseCSVFileManager(fileName: "gyroscope",
                                       bufferSize: 100,
                                       headerFields: ["Time", "EventType", "x", "y", "z"])
        
        fps = BaseCSVFileManager(fileName: "fps",
                                 bufferSize: 1,
                                 headerFields: ["Time", "EventType", "FPS"])
    }
}
