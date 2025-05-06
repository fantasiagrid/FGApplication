//
//  Untitled.swift
//  FG
//
//  Created by 윤서진 on 4/19/25.
//

import Foundation

// WebSocket Client 클래스
class WebSocketClient: NSObject, URLSessionWebSocketDelegate {
    var webSocketTask: URLSessionWebSocketTask?

    func connect() {
        // 서버 URI 설정
        guard let url = URL(string: "wss://a2eb-96-90-227-246.ngrok-free.app/ws") else {
            print("❌ Invalid URL")
            return
        }

        // URLSession 생성 (delegate 설정)
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)

        // 연결 시작
        webSocketTask?.resume()
        print("✅ Connecting to the server...")

        // 서버에 메시지 전송
        send(message: "Hello from local client!")

        // 파일 수신 시작
        receive()
    }

    func send(message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("❌ Sending error: \(error)")
            }
        }
    }

    func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("❌ Receiving error: \(error)")
            case .success(let message):
                switch message {
                case .data(let data):
                    let fileName = "received_model_local.usdz"
                    self?.saveFile(data: data, fileName: fileName)
                case .string(let text):
                    print("📩 Received text: \(text)")
                @unknown default:
                    print("❓ Unknown message received")
                }

                // 다음 메시지 계속 수신
                self?.receive()
            }
        }
    }

    func saveFile(data: Data, fileName: String) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

        if let documentDirectory = urls.first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)

            do {
                try data.write(to: fileURL)
                print("✅ .usdz file received and saved at \(fileURL.path)")
            } catch {
                print("❌ Failed to save file: \(error)")
            }
        }
    }

    // 연결이 완료되었을 때 호출됨
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket connected!")
    }

    // 연결이 닫혔을 때 호출됨
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("🔌 WebSocket disconnected")
    }
}
