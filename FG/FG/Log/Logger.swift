//
//  Logger.swift
//  Location
//
//  Created by 윤서진 on 10/27/24.
//

import Foundation

enum LogType {
    case info
    case warning
    case error
    
    func logMessage() -> String {
        switch self {
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        }
    }
}

class Logger {
    static let shared = Logger()
    private init() {}

    func log(message: String, type: LogType = .info) {
        let currentDate = Date()
        let calendar = Calendar.current

        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        let hour = calendar.component(.hour, from: currentDate)
        let minute = calendar.component(.minute, from: currentDate)
        let second = calendar.component(.second, from: currentDate)
        
        
        let dateStr = "\(year).\(month).\(day) \(hour):\(minute):\(second)"
        
        print("\(type.logMessage()), \(dateStr) [LOG]: \(message)")
    }
    
    func info(message: String) {
        Logger.shared.log(message: message, type: .info)
    }
    
    func error(message: String) {
        Logger.shared.log(message: message, type: .error)
    }
}
