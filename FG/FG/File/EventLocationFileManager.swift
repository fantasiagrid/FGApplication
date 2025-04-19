//
//  EventLocationFileManager.swift
//  FG
//
//  Created by 윤서진 on 4/14/25.
//

import Foundation

class EventLocationFileManager {
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
        
        if FileManager.default.fileExists(atPath: self.fileURL.path) {
            deleteFile(at: self.fileURL)
            createNewFile(at: self.fileURL)
        } else {
            createNewFile(at: self.fileURL)
        }
    }
}

// MARK: Monitoring
extension EventLocationFileManager {
    func receiveGeograpicData(eventType: String, latitude: Double, longitude: Double) {
        let formattedTime = formatter.string(from: Date())
        let description = ""
        let newRow = "\(eventType),\(formattedTime),\(latitude),\(longitude),\(description)\n"
        
        appendToFile(fileURL: self.fileURL, rows: [newRow])
    }
}

// MARK: File handling
extension EventLocationFileManager {
    func deleteFile(at fileURL: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: fileURL)
            print("\(fileURL.path) is deleted")
        } catch {
            print("\(fileURL.path) is not deleted. Error: \(error)")
        }
    }
    
    func createNewFile(at fileURL: URL) {
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
