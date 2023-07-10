//
//  Enemy.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit

enum EnemyState {
    case sleeping, explaining, waiting, thinking, celebrating, crying
}

protocol Enemy {
    var view: EnemyView { get }

    var state: EnemyState { get set }

    func wakeUp()
    func wait()
}

final class EnemyLogic: Enemy {
    var view: EnemyView

    var state = EnemyState.sleeping {
        didSet {
            /*
            self.removeAllActions()
            switch state {

            case .sleeping:
                <#code#>
            case .explaining:
                <#code#>
            case .waiting:
                <#code#>
            case .thinking:
                <#code#>
            case .celebrating:
                <#code#>
            case .crying:
                <#code#>
            }
            */

            if oldValue == .sleeping && state == .explaining {
                view.wakeUp()
            }

            if state == .thinking {
                view.think()
            }

            if state == .waiting {
                view.wait()
            }

            if state == .celebrating {
                view.celebrate()
            }

            if state == .crying {
                view.cry()
            }
        }
    }

    init(view: EnemyView, state: EnemyState = EnemyState.sleeping) {
        self.view = view
        self.state = state
    }

    func wakeUp() {
         state = .explaining
    }

    func wait() {
        state = .waiting
    }
}

protocol EnemyView {
    func stopAnimations()

    func wakeUp()
    func think()
    func wait()
    func celebrate()
    func cry()
}

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
