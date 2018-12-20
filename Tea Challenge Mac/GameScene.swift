//
//  GameScene.swift
//  Tea Challenge Mac
//
//  Created by Eduardo Irias on 12/19/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit
import GameplayKit

class Chip: SKSpriteNode {
    var boxIndex: Int!
    var box: String!
}

class GameScene: SKScene {
    static let config = [3,2,4]
    
    var state = GameState.playing
    
    var chips = [[Chip]]()
    var board: AAPLBoard!
    let strategist = GKMinmaxStrategist()
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var spinnyNode : SKShapeNode?
    
    var currentChips = [Chip]()
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        self.strategist.maxLookAheadDepth = 100
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        
        let node = Chip(color: NSColor.green, size: CGSize(width: 150, height: 50))
        node.name = "button"
        node.position.x = 100
        node.position.y = 100
        self.addChild(node)
        
        let resetNode = Chip(color: NSColor.red, size: CGSize(width: 150, height: 50))
        resetNode.name = "reset"
        resetNode.position.x = -100
        resetNode.position.y = 100
        self.addChild(resetNode)
        
        resetBoard()
    }
    
    func resetBoard() {
        
        currentChips.removeAll()
        
        for box in chips {
            box.forEach({ (chip) in
                chip.removeFromParent()
            })
        }
        chips.removeAll()
        
        board = AAPLBoard(chips: GameScene.config as [NSNumber])

        let padding: CGFloat = 60
        var mult: CGFloat = 1
        var multY: CGFloat = 1
        for (index, chip) in GameScene.config.enumerated() {
            chips.append([])
            if index == 2 {
                multY *= -1
            }
            
            var position: CGFloat = 40.0
            for _ in 0..<chip {
                self.addBox(x: position * mult, y: 40 * multY, box: index)
                position += padding
            }
            mult *= -1
        }
        
        self.strategist.gameModel = self.board
        
        state = .playing

    }
    
    func addBox(x: CGFloat, y: CGFloat, box: Int) {
        let node = Chip(color: NSColor.red, size: CGSize(width: 50, height: 50))
        node.name = "chip"
        node.boxIndex = box
        node.box = "box\(index)"
        node.position.x = x
        node.position.y = y
        self.addChild(node)
        self.chips[box].append(node)
    }
    
    func isWinner() -> Bool {
        if board.isWin(for: board.currentPlayer) {
            if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                n.position = CGPoint(x: 0, y: 0)
                n.strokeColor = SKColor.systemPink
                self.addChild(n)
            }
            return true
        }
        return false
    }
    
    func removeSelectedChips() {
        guard let index = currentChips.first?.boxIndex else { return }
        
        self.chips[index].removeAll { (chip) -> Bool in
            return currentChips.contains(chip)
        }
        board.removeChips(currentChips.count, inColumn: index)
        
        for currentChip in currentChips {
            currentChip.removeFromParent()
        }
        currentChips.removeAll()
    }
    
    func removeSelectedChipsAndEvaluateWinner() -> Bool {
        removeSelectedChips()
        return isWinner()
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
        
        if let _ = self.nodes(at: pos).first(where: { $0.name == "reset"}) {
            self.resetBoard()
        }
        
        if state == .thinking { return }
        
        if let _ = self.nodes(at: pos).first(where: { $0.name == "button"}) {
            self.state = .thinking
            if self.removeSelectedChipsAndEvaluateWinner() {
                print("You WON!")
                self.state = .ended
                return
            }
            self.board.currentPlayer = self.board.currentPlayer.opponent
            
            DispatchQueue.global(qos: .default).async {
                let aiMove : AAPLMove = self.strategist.bestMove(for: self.board.currentPlayer) as! AAPLMove
                
                for index in 0..<aiMove.chipsCount {
                    self.currentChips.append(self.chips[aiMove.column][index])
                }
                
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                    if self.removeSelectedChipsAndEvaluateWinner() {
                        print("Machine WON!")
                        self.state = .ended
                        return
                    }
                    self.board.currentPlayer = self.board.currentPlayer.opponent
                    self.state = .playing
                })
                
            }
            
            return
        }
        
        if state != .playing { return }
        
        if let box = self.nodes(at: pos).first(where: { $0.name == "chip"}) as? Chip {
            if currentChips.contains(box) { return }
            if box.boxIndex != currentChips.first?.boxIndex {
                for currentChip in currentChips {
                    currentChip.color = NSColor.red
                }
                currentChips.removeAll()
            }
            box.color = NSColor.gray
            currentChips.append(box)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
