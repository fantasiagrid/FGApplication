//
//  CSVManager.swift
//  Location
//
//  Created by 윤서진 on 3/7/25.
//

import Foundation

class LocationFileManager {
    private let fileName: String
    private let fileURL: URL
    private let bufferSize: Int
    private let formatter = ISO8601DateFormatter()
    
    private var dates: [Date] = []
    private var latitudes: [Double] = []
    private var longitudes: [Double] = []
    
    init(fileName: String, bufferSize: Int = 10) {
        self.fileName = "\(fileName).csv"
        self.fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        self.bufferSize = bufferSize
        
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if FileManager.default.fileExists(atPath: self.fileURL.path) == false {
            createNewFile(fileURL: self.fileURL)
        }
    }
}

// MARK: Monitoring
extension LocationFileManager {
    func startMonitoring() {
        let eventType = "startMonitoring"
        let formattedTime = formatter.string(from: Date())
        let latitude = ""
        let longitude = ""
        let description = ""
        let newRow = "\(eventType),\(formattedTime),\(latitude),\(longitude),\(description)\n"
        appendToFile(fileURL: self.fileURL, rows: [newRow])
        
        Logger.shared.log(message: "Start monitoring: \(newRow)")
    }
    
    func stopMonitoring() {
        flush()
        let eventType = "stopMonitoring"
        let formattedTime = formatter.string(from: Date())
        let latitude = ""
        let longitude = ""
        let description = ""
        let newRow = "\(eventType),\(formattedTime),\(latitude),\(longitude),\(description)\n"
        
        appendToFile(fileURL: self.fileURL, rows: [newRow])
        Logger.shared.log(message: "Stop monitoring: \(newRow)")
    }
}

// MARK: Write data
extension LocationFileManager {
    func flush() {
        guard latitudes.count == longitudes.count else {
            Logger.shared.log(message: "⚠️ Dimension mismatch in buffered data")
            return
        }

        var rows: [String] = []
        for i in 0..<latitudes.count {
            let eventType = "Receive"
            let formattedTime = formatter.string(from: dates[i])
            let description = ""
            let newRow = "\(eventType),\(formattedTime),\(latitudes[i].description),\(longitudes[i].description),\(description)\n"
            rows.append(newRow)
        }
        appendToFile(fileURL: self.fileURL, rows: rows)

        // Clear buffers after saving
        self.latitudes.removeAll()
        self.longitudes.removeAll()
        
        // Log
        Logger.shared.log(message: "Flushed")
    }
    
    func recordLocationData(latitude: Double, longitude: Double) {
        dates.append(Date())
        latitudes.append(latitude)
        longitudes.append(longitude)
        
        if latitudes.count >= self.bufferSize {
            flush()
        }
    }
    
    func saveError(description: String) {
        flush()
        
        let eventType = "Error"
        let formattedTime = formatter.string(from: Date())
        let latitude = ""
        let longitude = ""
        let newRow = "\(eventType),\(formattedTime),\(latitude),\(longitude),\(description)\n"
        appendToFile(fileURL: self.fileURL, rows: [newRow])
    }
}

// MARK: File handling
extension LocationFileManager {
    func createNewFile(fileURL: URL) {
        let header = "EventType,Time,Latitude,Longitude,Description\n"
        do {
            try (header).write(to: fileURL, atomically: true, encoding: .utf8)
            Logger.shared.log(message: "CSV file created at \(fileURL.path)")
        } catch {
            Logger.shared.log(message: "Error creating CSV file: \(error)")
        }
    }

    func appendToFile(fileURL: URL, rows: [String]) {
        guard let fileHandle = try? FileHandle(forWritingTo: fileURL) else {
            Logger.shared.log(message: "Failed to open file for appending")
            return
        }
        defer { fileHandle.closeFile() }

        fileHandle.seekToEndOfFile()
        
        for row in rows {
            if let rowData = row.data(using: .utf8) {
                fileHandle.write(rowData)
            }
        }
    }
}
