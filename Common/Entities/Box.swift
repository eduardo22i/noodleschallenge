//
//  Box.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit

protocol Box {
    var index: Int { get }
    var type: BoxType { get }
    var chips: [Chip] { get }

    func addCoins(count: Int)
    func addCoin(x: CGFloat, y: CGFloat)
    func remove(chips: [Chip])

    // Remove from parent to clean up the scene
    func removeFromParent()
}

enum BoxType: String {
    case centerTop = "BoxCenterTop"
    case leftBottom = "BoxLeftBottom"
    case rightBottom = "BoxRightBottom"
    case elseB = "Paper"
    
    var offsetX: Double {
        switch self {
        case .leftBottom:
            return 10.0
        case .rightBottom:
            return -10.0
        default:
            return 0.0
        }
    }
}

final class BoxSK: SKSpriteNode, Box {
    var index: Int
    
    var type: BoxType
    var chips = [Chip]()
    
    init(index: Int, type: BoxType = .elseB) {
        self.type = type
        self.index = index
        
        let texture = SKTexture(imageNamed: type.rawValue)
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
    
    func addCoins(count: Int) {
        for coinIndex in 0..<count {
            let separation = 52.0
            let offset = Double(coinIndex) / Double(count)
            let angle =  offset * Double.pi * 2.0
            let x = sin(angle) * separation + self.type.offsetX
            let y = cos(angle) * separation + 30.0
            self.addCoin(x: CGFloat(x), y: CGFloat(y))
        }
    }
    
    func addCoin(x: CGFloat, y: CGFloat) {
        
        let coin = Chip(boxIndex: index)
        coin.position.x = x
        coin.position.y = y
        coin.zPosition = 3
        
        self.addChild(coin)
        self.chips.append(coin)
    }
}
