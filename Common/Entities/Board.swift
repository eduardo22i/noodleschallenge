//
//  Board.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit

protocol Board {

    var gameModel: AAPLBoard! { get set }

    var boxes: [Box] { get }

    func reset()
    func remove(chips: [Chip])
}

final class BoardSK: SKSpriteNode, Board {

    var gameModel: AAPLBoard!
    
    private (set) var boxes: [Box] = [BoxSK]()
    
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
            box.chips.forEach({ (chip) in
                chip.removeFromParent()
            })
            box.removeFromParent()
        }
        boxes.removeAll()
        
        gameModel = AAPLBoard(chips: config as [NSNumber])
        
        for (index, chipsCount) in self.config.enumerated() {
            
            let x = index == 0 ? -160 : (index == 1 ? 200 : 0)
            let y = index == 0 ? -40 : (index == 2 ? 200 : -40)
            
            let box = self.addBox(index: index, x: CGFloat(x), y: CGFloat(y))
            box.addCoins(count: chipsCount)
            boxes.append(box)
            
        }
    }
    
    func remove(chips: [Chip]) {
        guard let index = chips.first?.boxIndex else { return }
        
        self.boxes[index].remove(chips: chips)
        self.gameModel.removeChips(chips.count, inColumn: index)
    }
    
    private func addBox(index: Int, x: CGFloat, y: CGFloat) -> Box {
        
        let type: BoxType = {
            switch index {
            case 0:
                return BoxType.leftBottom
            case 1:
                return BoxType.rightBottom
            case 2:
                return BoxType.centerTop
            default:
                return BoxType.elseB
            }
            
        }()
        
        let box = BoxSK(index: index, type: type)
        box.position.x = x
        box.position.y = y
        box.zPosition = 2
        self.addChild(box)
        
        return box
    }
    
}
