//
//  Chip.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit

class Chip: SKSpriteNode {
    var boxIndex: Int!
    var box: String!
    
    init() {
        let texture = SKTexture(imageNamed: "Coin")
        super.init(texture: texture, color: NSColor.clear, size: texture.size())
        
        self.name = "coin"
        self.normalTexture = SKTexture(imageNamed: "CoinNormal")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
