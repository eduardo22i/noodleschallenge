//
//  Chip.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit

protocol Chip: AnyObject {
    var index: UUID { get }
    var boxIndex: Int { get }
    var box: String { get }

    var isSelected: Bool { get set }

    /// Remove from parent to clean up the scene
    func removeFromParent()

}

final class ChipSK: SKSpriteNode, Chip {
    var index = UUID()
    let boxIndex: Int
    let box: String
    
    var isSelected = false {
        didSet {
            self.alpha = isSelected ? 0.4 : 1.0
        }
    }
    
    init(boxIndex: Int, index: Int) {
        let texture = SKTexture(imageNamed: "Coin")

//        self.index = index
        self.boxIndex = boxIndex
        self.box = "box\(boxIndex)"
        
        super.init(texture: texture, color: NSColor.clear, size: texture.size())
        
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
}
