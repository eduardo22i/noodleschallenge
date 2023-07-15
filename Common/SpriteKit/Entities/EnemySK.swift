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
        let texture = Asset.Enemies.Obinoby.obinobySleeping.skTexture
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
        self.texture = Asset.Enemies.Obinoby.obinobyWakeUp.skTexture

        self.run(SKAction.animate(
            with: [
                Asset.Enemies.Obinoby.obinobySleeping.skTexture,
                Asset.Enemies.Obinoby.obinobyWakeUp.skTexture
            ],
            timePerFrame: 0.4,
            resize: false,
            restore: true)
        )
    }

    func think() {
        self.texture = Asset.Enemies.Obinoby.obinobyThinkingA1.skTexture

        let textures = { () -> [SKTexture] in
            switch Int.random(in: 0 ..< 4) {
            case 0:
                return [
                    Asset.Enemies.Obinoby.obinobyThinkingA1.skTexture,
                    Asset.Enemies.Obinoby.obinobyThinkingA2.skTexture
                ]
            case 1:
                return [
                    Asset.Enemies.Obinoby.obinobyThinkingA2.skTexture,
                        Asset.Enemies.Obinoby.obinobyThinkingA3.skTexture
                ]
            case 2:
                return [
                    Asset.Enemies.Obinoby.obinobyThinkingA3.skTexture,
                    Asset.Enemies.Obinoby.obinobyThinkingA4.skTexture
                ]
            case 4:
                return [
                    Asset.Enemies.Obinoby.obinobyThinkingA1.skTexture,
                    Asset.Enemies.Obinoby.obinobyThinkingA4.skTexture
                ]
            default:
                return [
                    Asset.Enemies.Obinoby.obinobyThinkingA1.skTexture,
                    Asset.Enemies.Obinoby.obinobyThinkingA2.skTexture
                ]
            }
        }()

        self.run(
            SKAction.repeatForever(
                SKAction.animate(
                    with: textures,
                    timePerFrame: 0.5,
                    resize: false,
                    restore: true
                )
            )
        )
    }

    func wait() {
        self.texture = Asset.Enemies.Obinoby.obinobyWaiting.skTexture

        var speed = 0.5
        let textures = { () -> [SKTexture] in
            switch Int.random(in: 0 ..< 3) {
            case 0:
                return [
                    Asset.Enemies.Obinoby.obinobyWaitingB1.skTexture,
                    Asset.Enemies.Obinoby.obinobyWaitingB2.skTexture
                ]
            case 1:
                speed = 0.3
                return [
                    Asset.Enemies.Obinoby.obinobyWaitingC1.skTexture,
                    Asset.Enemies.Obinoby.obinobyWaitingC2.skTexture,
                    Asset.Enemies.Obinoby.obinobyWaitingC1.skTexture,
                    Asset.Enemies.Obinoby.obinobyWaitingC3.skTexture,
                    Asset.Enemies.Obinoby.obinobyWaitingC4.skTexture,
                    Asset.Enemies.Obinoby.obinobyWaitingC3.skTexture
                ]
            default:
                return [
                    Asset.Enemies.Obinoby.obinobyWaiting.skTexture,
                    Asset.Enemies.Obinoby.obinobyNo.skTexture
                ]
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
        self.texture = Asset.Enemies.Obinoby.obinobyCelebratingA1.skTexture

        let textures = [
            Asset.Enemies.Obinoby.obinobyCelebratingA1.skTexture,
            Asset.Enemies.Obinoby.obinobyCelebratingA2.skTexture,
            Asset.Enemies.Obinoby.obinobyCelebratingA3.skTexture,
            Asset.Enemies.Obinoby.obinobyCelebratingA2.skTexture,
            Asset.Enemies.Obinoby.obinobyCelebratingA3.skTexture
        ]

        self.run(
            SKAction.repeatForever(
                SKAction.animate(
                    with: textures,
                    timePerFrame: 0.3,
                    resize: false,
                    restore: true
                )
            )
        )
    }

    func cry() {
        self.texture = Asset.Enemies.Obinoby.obinobySurpriseA1.skTexture

        let textures = [Asset.Enemies.Obinoby.obinobySurpriseA1.skTexture, Asset.Enemies.Obinoby.obinobySurpriseA2.skTexture]

        self.run(
            SKAction.repeatForever(
                SKAction.animate(
                    with: textures,
                    timePerFrame: 0.5,
                    resize: false,
                    restore: true
                )
            )
        )
    }
}
