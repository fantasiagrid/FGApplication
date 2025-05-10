//
//  FPS.swift
//  FG
//
//  Created by 윤서진 on 5/3/25.
//

import Foundation
import QuartzCore

@Observable class FPSCounter {
    var fps: Int = 0
    var isMonitoring: Bool = false
    
    private var displaylink: CADisplayLink!
    private var lastUpdate = Date()
    private var frameCount: Int = 0
    
    func startMonitoring() {
        displaylink = CADisplayLink(target: self, selector: #selector(tick))
        displaylink.add(to: .current, forMode: .default)
        
        isMonitoring = true
        
        Logger.shared.log(message: "fps monitoring started")
        
        DummyFileManager.shared.fps.append(date: Date(), values: ["startMonitoring", ""])
    }
    
    func stopMonitoring() {
        displaylink?.invalidate()
        displaylink = nil
        
        isMonitoring = false
        
        Logger.shared.log(message: "fps monitoring stopped")
        
        DummyFileManager.shared.fps.append(date: Date(), values: ["stopMonitoring", ""])
    }
    
    @objc func tick() {
        frameCount += 1
        
        let now = Date()
        let elapsed = now.timeIntervalSince(lastUpdate)
        if elapsed >= 1.0 {
            fps = Int(Double(frameCount) / elapsed)
            frameCount = 0
            lastUpdate = now
            
            DummyFileManager.shared.fps.append(date: Date(), values: ["receive", fps.description])
        }
    }
}
