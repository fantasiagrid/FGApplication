//
//  BaseFileManager.swift
//  FG
//
//  Created by 윤서진 on 5/6/25.
//

import Foundation

class BaseCSVFileManager {
    let fileName: String
    let headerFields: [String]
    let fileURL: URL
    
    private let bufferSize: Int
    private let formatter: ISO8601DateFormatter
    private var dates: [Date] = []
    private var values: [[String]] = []

    init(fileName: String, bufferSize: Int, headerFields: [String]) {
        self.fileName = "\(fileName).csv"
        self.fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(self.fileName)
        self.bufferSize = bufferSize
        self.formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        self.headerFields = headerFields
        if FileManager.default.fileExists(atPath: fileURL.path) {
            deleteFile(at: fileURL)
        }
        createFile(at: fileURL)
    }
    
    func append(date: Date, values: [String]) {
        self.dates.append(date)
        self.values.append(values)
    
        if self.dates.count >= bufferSize {
            flush()
        }
    }
    
    func startMonitoring(date: Date) {
        self.dates.append(date)
        self.values.append(["start monitoring"] + Array(repeating: "", count: headerFields.count - 2)) // Header에서 Time과 Event type을 제외
        Logger.shared.log(message: "\(fileName), start monitoring")
    }
    
    func stopMonitoring(date: Date) {
        self.dates.append(date)
        self.values.append(["stop monitoring"] + Array(repeating: "", count: headerFields.count - 2)) // Header에서 Time과 Event type을 제외
        
        Logger.shared.log(message: "\(fileName), stop monitoring")
        
        flush()
    }    
}

// MARK: File handling
extension BaseCSVFileManager {
    private func createFile(at fileURL: URL) {
        let header = headerFields.joined(separator: ",") + "\n"
        do {
            try header.write(to: fileURL, atomically: true, encoding: .utf8)
            Logger.shared.log(message: "\(fileName), CSV file created at \(fileURL.path)")
        } catch {
            Logger.shared.log(message: "\(fileName), Error creating CSV file: \(error)")
        }
    }
    
    private func deleteFile(at fileURL: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: fileURL)
            Logger.shared.log(message: "\(fileName), \(fileURL.path) is deleted")
        } catch {
            Logger.shared.log(message: "\(fileName), \(fileURL.path) is not deleted. Error: \(error)")
        }
    }
}

// MARK: Contents
extension BaseCSVFileManager {
    private func flush() {
        guard let handle = try? FileHandle(forWritingTo: fileURL) else { return }
        defer { handle.closeFile() }

        for (i, date) in dates.enumerated() {
            let row = ([formatter.string(from: date)] + values[i].map { "\($0)" }).joined(separator: ",") + "\n"
            if let data = row.data(using: .utf8) {
                handle.seekToEndOfFile()
                handle.write(data)
            }
        }
        dates.removeAll()
        values.removeAll()
    }
}

