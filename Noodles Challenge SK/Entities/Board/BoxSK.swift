//
//  BoxSK.swift
//  Noodles Challenge iOS
//
//  Created by Eduardo Irias on 7/11/23.
//  Copyright © 2023 Estamp. All rights reserved.
//

import SpriteKit

final class BoxSK: SKSpriteNode, BoxView {
    var index: Int

    var type: BoxType

    init(index: Int, type: BoxType = .elseB) {
        self.type = type
        self.index = index

        let texture = SKTexture(imageNamed: type.rawValue)
        super.init(texture: texture, color: .clear, size: texture.size())

        self.name = "box"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func remove(chips: [any ChipView]) {

        for currentChip in (chips as? [ChipSK] ?? []) {
            let actions = [
                SKAction.wait(forDuration: 0.1),
                SKAction.scale(by: 2.0, duration: 0.1),
                SKAction.run {
                    currentChip.removeFromParent()
                }
            ]
            currentChip.run(SKAction.sequence(actions))
        }
    }

    func addChip(index: Int, total: Int) -> ChipView {

        let separation = 52.0
        let offset = Double(index) / Double(total)
        let angle =  offset * Double.pi * 2.0
        let x = sin(angle) * separation + self.type.offsetX
        let y = cos(angle) * separation + 30.0

        let coin = ChipSK()
        coin.position.x = x
        coin.position.y = y
        coin.zPosition = 3

        self.addChild(coin)
        return coin
    }
}
