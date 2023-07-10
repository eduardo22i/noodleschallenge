//
//  EnemySK.swift
//  Noodles Challenge iOS
//
//  Created by Eduardo Irias on 7/11/23.
//  Copyright © 2023 Estamp. All rights reserved.
//

import SpriteKit

final class EnemySK: SKSpriteNode, EnemyView {

    init(name: String) {
        let texture = SKTexture(imageNamed: "\(name)-Sleeping")
        super.init(texture: texture, color: NSColor.clear, size: texture.size())

        self.name = name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func stopAnimations() {
        removeAllActions()
    }

    func wakeUp() {
        self.texture = SKTexture(imageNamed: "\(self.name!)-WakeUp")

        self.run(SKAction.animate(with: [SKTexture(imageNamed: "\(self.name!)-Sleeping"), SKTexture(imageNamed: "\(self.name!)-WakeUp")],
                                  timePerFrame: 0.4,
                                  resize: false,
                                  restore: true)
        )
    }

    func think() {
        self.texture = SKTexture(imageNamed: "\(self.name!)-ThinkingA1")

        let textures = { () -> [SKTexture] in
            switch Int.random(in: 0 ..< 4) {
            case 0:
                return [SKTexture(imageNamed: "\(self.name!)-ThinkingA1"), SKTexture(imageNamed: "\(self.name!)-ThinkingA2")]
            case 1:
                return [SKTexture(imageNamed: "\(self.name!)-ThinkingA2"),
                        SKTexture(imageNamed: "\(self.name!)-ThinkingA3")]
            case 2:
                return [SKTexture(imageNamed: "\(self.name!)-ThinkingA3"), SKTexture(imageNamed: "\(self.name!)-ThinkingA4")]
            case 4:
                return [SKTexture(imageNamed: "\(self.name!)-ThinkingA1"), SKTexture(imageNamed: "\(self.name!)-ThinkingA4")]
            default:
                return [SKTexture(imageNamed: "\(self.name!)-ThinkingA1"), SKTexture(imageNamed: "\(self.name!)-ThinkingA2")]
            }
        }()

        self.run(
            SKAction.repeatForever(
                SKAction.animate(with: textures,
                                 timePerFrame: 0.5,
                                 resize: false,
                                 restore: true)
            )
        )
    }

    func wait() {
        self.texture = SKTexture(imageNamed: "\(self.name!)-Waiting")

        var speed = 0.5
        let textures = { () -> [SKTexture] in
            switch Int.random(in: 0 ..< 3) {
            case 0:
                return [SKTexture(imageNamed: "\(self.name!)-WaitingB1"), SKTexture(imageNamed: "\(self.name!)-WaitingB2")]
            case 1:
                speed = 0.3
                return [SKTexture(imageNamed: "\(self.name!)-WaitingC1"), SKTexture(imageNamed: "\(self.name!)-WaitingC2"),
                        SKTexture(imageNamed: "\(self.name!)-WaitingC1"),
                        SKTexture(imageNamed: "\(self.name!)-WaitingC3"), SKTexture(imageNamed: "\(self.name!)-WaitingC4"),
                        SKTexture(imageNamed: "\(self.name!)-WaitingC3")
                ]
            default:
                return [SKTexture(imageNamed: "\(self.name!)-Waiting"), SKTexture(imageNamed: "\(self.name!)-No")]
            }
        }()

        self.run(
            SKAction.repeatForever(
                SKAction.animate(with: textures,
                                 timePerFrame: speed,
                                 resize: false,
                                 restore: true)
            )
        )
    }

    func celebrate() {
        self.texture = SKTexture(imageNamed: "\(self.name!)-CelebratingA1")

        let textures = [SKTexture(imageNamed: "\(self.name!)-CelebratingA1"), SKTexture(imageNamed: "\(self.name!)-CelebratingA2"),
                        SKTexture(imageNamed: "\(self.name!)-CelebratingA3"),
                        SKTexture(imageNamed: "\(self.name!)-CelebratingA2"),
                        SKTexture(imageNamed: "\(self.name!)-CelebratingA3")]

        self.run(
            SKAction.repeatForever(
                SKAction.animate(with: textures,
                                 timePerFrame: 0.3,
                                 resize: false,
                                 restore: true)
            )
        )
    }

    func cry() {
        self.texture = SKTexture(imageNamed: "\(self.name!)-SurpriseA1")

        let textures = [SKTexture(imageNamed: "\(self.name!)-SurpriseA1"), SKTexture(imageNamed: "\(self.name!)-SurpriseA2")]

        self.run(
            SKAction.repeatForever(
                SKAction.animate(with: textures,
                                 timePerFrame: 0.5,
                                 resize: false,
                                 restore: true)
            )
        )
    }
}
