//
//  AnimationHelper.swift
//  FG
//
//  Created by 윤서진 on 5/26/25.
//

import RealityFoundation

extension Entity {
    func playRepeatAnimation() {
        guard let animation = self.availableAnimations.first else { return }
        let repeatedAnimation = animation.repeat(count: .max)
        self.playAnimation(repeatedAnimation, transitionDuration: 1, startsPaused: false)
    }
    
    func applyFloatingAnimation(extra_y: Float = 0.05, duration: Float = 2.0) {
        let goUp = FromToByAnimation<Transform>(
                    name: "goUp",
                    from: self.transform,
                    to: .init(scale: self.transform.scale,
                              rotation: self.transform.rotation,
                              translation: self.position + .init(x: 0, y: extra_y, z: 0)),
                    duration: Double(duration / 2), // 이 Animation이 1초 동안 유지됨
                    timing: .easeOut, // 처음엔 빠르고, 끝에 가까워질수록 느려지는 방식
                    bindTarget: .transform)
        
        let goDown = FromToByAnimation<Transform>(
                    name: "goDown",
                    from: .init(scale: self.transform.scale,
                                rotation: self.transform.rotation,
                                translation: self.position + .init(x: 0, y: extra_y, z: 0)),
                    to: self.transform,
                    duration: Double(duration / 2),
                    timing: .easeOut,
                    bindTarget: .transform)
        
        let goUpAnimation = try! AnimationResource.generate(with: goUp)
        let goDownAnimation = try! AnimationResource.generate(with: goDown)
        let animation = try! AnimationResource.sequence(with: [goUpAnimation, goDownAnimation]).repeat(count: .max)

        self.playAnimation(animation, transitionDuration: 0) // transitionDuration: animation transition duration
    }
}

