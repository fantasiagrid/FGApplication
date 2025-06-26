//
//  WebSocketClientBuffer.swift
//  FG
//
//  Created by 윤서진 on 4/26/25.
//

import Foundation

class WebSocketClientBuffer: NSObject, URLSessionWebSocketDelegate {
    var webSocketTask: URLSessionWebSocketTask?
    var fileBuffer = Data()
    var fileReceived = false
    private var fileName: String?
    var startCommTime: Date?

    let serverUrl: URL? = URL(string: "wss://e2b1-39-125-69-76.ngrok-free.app/ws")
    
    func connect() {
        guard let url = serverUrl else {
            print("🚨 Invalid URL")
            return
        }
        
        // Make session
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveFile()
        
        // Log
        Logger.shared.log(message: "Try to connect server", type: LogType.communication)
        startCommTime = Date()
    }
}

// MARK: Communication
extension WebSocketClientBuffer {
    func send(message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                Logger.shared.log(message: "error: \(error)", type: LogType.communication)
            }
        }
    }
    
    func receiveFile() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                Logger.shared.log(message: "error: \(error)", type: LogType.communication)
            case .success(let message):
                if case .string(let text) = message, text.hasPrefix("__FILE_START__") {
                    self.downloadStart(text: text)
                    self.receiveFile()
                } else if case .data(let data) = message {
                    self.downloading(data: data)
                    self.receiveFile()
                } else if case .string(let text) = message, text.hasPrefix("__FILE_END__") {
                    self.downloadEnd()
                    self.receiveFile()
                } else {
                    Logger.shared.log(message: "Unknown message", type: LogType.communication)
                    self.receiveFile()
                }
            }
        }
    }
}

// MARK: Connection delegate
extension WebSocketClientBuffer {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        // Start connection delegate
        Logger.shared.log(message: "WebSocket connected!", type: LogType.communication)
    }

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        // End connection delegate
        Logger.shared.log(message: "WebSocket disconnected!", type: LogType.communication)
    }
}

// MARK: Download File
extension WebSocketClientBuffer {
    private func downloadStart(text: String) {
        fileBuffer.removeAll()
        fileReceived = false
        Logger.shared.log(message: "text: \(text)", type: LogType.communication)
        fileName = String(text.dropFirst("__FILE_START__:".count))
    }
    
    private func downloading(data: Data) {
        self.fileBuffer.append(data)
        Logger.shared.log(message: "Chunk received, size:\(data.count) bytes", type: LogType.communication)
    }
    
    private func downloadEnd() {
        saveFile()
        fileReceived = true
    }
}

// MARK: Handle File
extension WebSocketClientBuffer {
    func saveFile() {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

        if let documentsDirectory = urls.first, let fileName = fileName {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try fileBuffer.write(to: fileURL)
                if let start = startCommTime {
                    let elapsed = Date().timeIntervalSince(start)
                    print("⏱️ Elapsed time: \(elapsed) seconds")
                }
                Logger.shared.log(message: "Saved at: \(fileURL.path)", type: LogType.communication)
            } catch {
                Logger.shared.log(message: "Error saving file: \(error)", type: LogType.communication)
            }
        }
    }
}
