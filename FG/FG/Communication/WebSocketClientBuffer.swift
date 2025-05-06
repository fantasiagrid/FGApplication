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
    let fileName = "received_model_buffered.usdz"
    var startTime: Date?

    func connect() {
        guard let url = URL(string: "wss://a2eb-96-90-227-246.ngrok-free.app/ws") else {
            print("🚨 Invalid URL")
            return
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        print("✅ Connecting to the server...")
        
        startTime = Date()

        send(message: "Hello from client!")
        receiveFile()
    }

    func send(message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("🚨 Sending error: \(error)")
            }
        }
    }

    func receiveFile() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("🚨 Receiving error: \(error)")
            case .success(let message):
                switch message {
                case .data(let data):
                    self.fileBuffer.append(data)
                    print("📦 Chunk received. Current size: \(self.fileBuffer.count) bytes")
                    self.receiveFile()

                case .string(let text):
                    if text == "__FILE_END__" {
                        self.saveFile()
                        self.fileReceived = true
                        print("✅ File fully received and saved!")
                        self.listenForMessages()
                    } else {
                        print("⚠️ Unexpected message during file transfer: \(text)")
                        self.receiveFile()
                    }

                @unknown default:
                    print("❓ Unknown message type")
                    self.receiveFile()
                }
            }
        }
    }

    func saveFile() {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

        if let documentsDirectory = urls.first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try fileBuffer.write(to: fileURL)
                if let start = startTime {
                    let elapsed = Date().timeIntervalSince(start)
                    print("⏱️ Elapsed time: \(elapsed) seconds")
                }
                print("🎥 Video saved at: \(fileURL.path)")
            } catch {
                print("🚨 Error saving file: \(error)")
            }
        }
    }

    func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("🚨 Receiving error after file: \(error)")
            case .success(let message):
                switch message {
                case .data(let data):
                    print("📨 Post-file binary message: \(data.count) bytes")
                case .string(let text):
                    print("📨 Post-file text message: \(text)")
                @unknown default:
                    print("❓ Unknown message after file")
                }
                self.listenForMessages()
            }
        }
    }

    // 연결 완료
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket connected!")
    }

    // 연결 종료
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("🔌 WebSocket disconnected")
    }
}
