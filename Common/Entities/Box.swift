//
//  Box.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit

class Box: SKSpriteNode {
    var index: Int!
    
    var chips = [Chip]()
    
    init(index: Int) {
        self.index = index
        
        let texture = SKTexture(imageNamed: "Paper")
        super.init(texture: texture, color: NSColor.clear, size: texture.size())
        
        self.name = "box"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func remove(chips: [Chip]) {        
        self.chips.removeAll { (chip) -> Bool in
            return chips.contains(chip)
        }
        
        for currentChip in chips {
            currentChip.removeFromParent()
        }
    }
    
    func addCoins(count: Int) {
        for coinIndex in 0..<count {
            let separation = 48.0
            let offset = Double(coinIndex) / Double(count)
            let angle =  offset * Double.pi * 2.0
            let x = sin(angle) * separation + 10.0
            let y = cos(angle) * separation + 30.0
            self.addCoin(x: CGFloat(x), y: CGFloat(y))
        }
    }
    
    func addCoin(x: CGFloat, y: CGFloat) {
        
        let node = Chip(boxIndex: index)
        node.position.x = x
        node.position.y = y
        node.zPosition = 3
        
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 40, height: 10))
        shadow.fillColor = NSColor.black
        shadow.strokeColor = NSColor.black
        shadow.alpha = 0.2
        node.addChild(shadow)
        shadow.position.y = -36
        shadow.zPosition = 1
        
        self.addChild(node)
        self.chips.append(node)
    }
    
}
