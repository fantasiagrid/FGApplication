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
    
    private var displaylink: CADisplayLink!
    private var lastUpdate = Date()
    private var frameCount: Int = 0
    
    init() {
        displaylink = CADisplayLink(target: self, selector: #selector(tick))
        displaylink.add(to: .current, forMode: .default)
    }
    
    @objc func tick() {
        frameCount += 1
        
        let now = Date()
        let elapsed = now.timeIntervalSince(lastUpdate)
        if elapsed >= 1.0 {
            fps = Int(Double(frameCount) / elapsed)
            frameCount = 0
            lastUpdate = now
        }
    }
}
