//
//  WebSocketVideoSender.swift
//  PHPickerViewController_Player_Picker_SwiftUI
//
//  Created by 윤서진 on 3/4/25.
//

import Foundation
import SocketIO

/*
let serverURL = "http://192.168.0.35:5001"
let videoClient = VideoSocketIOClient(serverURL: serverURL)
videoClient.connect()

// ✅ 비디오 파일 전송
DispatchQueue.global().asyncAfter(deadline: .now() + 2) {  // 서버 연결 후 2초 후 전송 시작
    videoClient.sendVideoFile(filePath: targetURL.path)
}
*/

class VideoSocketIOClient {
    private var manager: SocketManager
    private var socket: SocketIOClient
    private let chunkSize = 64 * 1024  // 64KB 청크 크기
    
    init(serverURL: String) {
        guard let url = URL(string: serverURL) else {
            fatalError("Invalid URL")
        }
        
        // manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        manager = SocketManager(socketURL: url, config: [.compress])
        socket = manager.defaultSocket
    }
    
    func connect() {
        socket.on(clientEvent: .connect) { _, _ in
            print("✅ Connected to Socket.IO server")
        }
        
        socket.on(clientEvent: .disconnect) { _, _ in
            print("❌ Disconnected from server")
        }
        
        socket.connect()
    }
    
    func sendVideoFile(filePath: String) {
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            print("🚨 Error: Cannot open file \(filePath)")
            return
        }

        let chunkSize = 64 * 1024  // 64KB per chunk

        var i = 0
        while true {
            let chunkData = fileHandle.readData(ofLength: chunkSize)
            if chunkData.isEmpty { break }  // End of file
            
            let base64Chunk = chunkData.base64EncodedString()
            
            print("emit video chunk \(i)")
            self.socket.emit("video_chunk", [
                "index" : i,
                "chunk": base64Chunk,
            ])
            i += 1
            
            usleep(100000)  // 🔥 Small delay (1s) prevents connection drop
        }

        fileHandle.closeFile()
        sendEndSignal()
    }
    
    private func sendEndSignal() {
        socket.emit("video_end")  // 전송 완료 신호
        print("✅ Video transmission complete.")
    }
}
