//
//  Board.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit

class Board: SKSpriteNode {

    var gameModel: AAPLBoard!
    
    var boxes = [[Chip]]()
    
    private var config = [Int]() {
        didSet {
            gameModel = AAPLBoard(chips: config as [NSNumber])
        }
    }
    
    init(config: [Int]) {
        let texture = SKTexture(imageNamed: "Board")
        super.init(texture: texture, color: NSColor.clear, size: texture.size())
        self.config = config
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    
    func reset() {
        
        for box in boxes {
            box.forEach({ (chip) in
                chip.removeFromParent()
            })
        }
        boxes.removeAll()
        
        gameModel = AAPLBoard(chips: config as [NSNumber])
        
        for (index, chip) in GameScene.config.enumerated() {
            boxes.append([])
            
            let x = index == 0 ? -200 : (index == 1 ? 200 : 0)
            let y = index == 0 ? 100 : (index == 2 ? -100 : 100)
            
            let box = self.addBox(x: CGFloat(x), y: CGFloat(y))
            
            for chipIndex in 0..<chip {
                let separation = 48.0
                let offset = Double(chipIndex) / Double(chip)
                let angle =  offset * Double.pi * 2.0
                let x = sin(angle) * separation + 10.0
                let y = cos(angle) * separation + 30.0
                self.addCoin(x: CGFloat(x), y: CGFloat(y), boxIndex: index, box: box)
            }
        }
        
    }
    
    private func addBox(x: CGFloat, y: CGFloat) -> SKSpriteNode {
        
        let node = SKSpriteNode(imageNamed: "Paper")
        node.normalTexture = SKTexture(imageNamed: "PaperNormal")
        node.name = "box"
        node.position.x = x
        node.position.y = y
        node.zPosition = 2
        //node.lightingBitMask = 1
        self.addChild(node)
        /*
         let light = SKLightNode()
         light.categoryBitMask = 1
         light.falloff = 3.0
         light.position.y = 0.0
         light.lightColor = NSColor.white
         light.shadowColor = NSColor.black
         node.addChild(light)
         */
        return node
    }
    
    private func addCoin(x: CGFloat, y: CGFloat, boxIndex: Int, box: SKSpriteNode) {
        
        let node = Chip()
        node.boxIndex = boxIndex
        node.box = "box\(boxIndex)"
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
        
        box.addChild(node)
        self.boxes[boxIndex].append(node)
    }
    
}
