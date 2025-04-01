//
//  CSVManager.swift
//  Location
//
//  Created by 윤서진 on 3/7/25.
//

import Foundation

class MotionFileManager {
    private let fileName: String
    private let fileURL: URL
    private let bufferSize: Int
    private let formatter = ISO8601DateFormatter()
    
    private var dates: [Date] = []
    private var xs: [Double] = []
    private var ys: [Double] = []
    private var zs: [Double] = []
    
    init(fileName: String, bufferSize: Int = 100) {
        self.fileName = "\(fileName).csv"
        self.fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        self.bufferSize = bufferSize
        
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if FileManager.default.fileExists(atPath: self.fileURL.path) == false {
            createNewFile(fileURL: self.fileURL)
        }
    }
}

// MARK: monitoring
extension MotionFileManager {
    func startMonitoring() {
        let eventType = "startMonitoring"
        let formattedTime = formatter.string(from: Date())
        let x = ""
        let y = ""
        let z = ""
        let description = ""
        let newRow = "\(eventType),\(formattedTime),\(x),\(y),\(z),\(description)\n"
        appendToFile(fileURL: self.fileURL, rows: [newRow])
        
        Logger.shared.log(message: "Start monitoring: \(newRow)")
    }
    
    func stopMonitoring() {
        flush()
        
        let eventType = "stopMonitoring"
        let formattedTime = formatter.string(from: Date())
        let x = ""
        let y = ""
        let z = ""
        let description = ""
        let newRow = "\(eventType),\(formattedTime),\(x),\(y),\(z),\(description)\n"
        
        appendToFile(fileURL: self.fileURL, rows: [newRow])
        Logger.shared.log(message: "Stop monitoring: \(newRow)")
    }
}
    
// MARK: Write data
extension MotionFileManager {
    func recordMotionData(x: Double, y: Double, z: Double) {
        dates.append(Date())
        xs.append(x)
        ys.append(y)
        zs.append(z)
        
        if xs.count >= bufferSize {
            flush()
        }
    }
    
    func flush() {
        guard xs.count == ys.count, ys.count == zs.count else {
            Logger.shared.log(message: "⚠️ Dimension mismatch in buffered data")
            return
        }

        var rows: [String] = []
        for i in 0..<xs.count {
            let eventType = "Receive"
            let formattedTime = formatter.string(from: dates[i])
            let description = ""
            let newRow = "\(eventType),\(formattedTime),\(xs[i]),\(ys[i]),\(zs[i]),\(description)\n"
            rows.append(newRow)
        }
        appendToFile(fileURL: self.fileURL, rows: rows)

        // Clear buffers after saving
        xs.removeAll()
        ys.removeAll()
        zs.removeAll()
        
        // Log
        Logger.shared.log(message: "Flushed")
    }
    
    func saveError(description: String) {
        flush()
        
        let eventType = "Error"
        let formattedTime = formatter.string(from: Date())
        let x = ""
        let y = ""
        let z = ""
        let newRow = "\(eventType),\(formattedTime),\(x),\(y),\(z),\(description)\n"
        appendToFile(fileURL: self.fileURL, rows: [newRow])
    }
}

// MARK: File handling
extension MotionFileManager {
    func createNewFile(fileURL: URL) {
        let header = "EventType,Time,x,y,z,Description\n"
        do {
            try header.write(to: fileURL, atomically: true, encoding: .utf8)
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
