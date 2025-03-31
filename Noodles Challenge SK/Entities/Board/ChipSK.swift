//
//  ChipSK.swift
//  Noodles Challenge iOS
//
//  Created by Eduardo Irias on 7/11/23.
//  Copyright © 2023 Estamp. All rights reserved.
//

import SpriteKit

final class ChipSK: SKSpriteNode, ChipView {
    weak var chip: (any ChipControllable)?

    init() {
        let texture = SKTexture(imageNamed: "Coin")

        super.init(texture: texture, color: .clear, size: texture.size())

        self.name = "coin"

        let shadow = SKSpriteNode(imageNamed: "CoinShadow")
        shadow.scale(to: CGSize(width: 38, height: 12))
        shadow.alpha = 0.8
        shadow.colorBlendFactor = 0.2
        self.addChild(shadow)
        shadow.position.y = -36
        shadow.zPosition = 1
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(status: Bool) {
        self.alpha = status ? 0.4 : 1.0
    }
}
