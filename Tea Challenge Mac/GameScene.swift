//
//  GameScene.swift
//  Tea Challenge Mac
//
//  Created by Eduardo Irias on 12/19/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    static let config = [3,2,4]
    
    var state = GameState.playing
    
    let board = Board(config: GameScene.config)

    let strategist = GKMinmaxStrategist()
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var spinnyNode : SKShapeNode?
    
    var currentChips = [Chip]()
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        self.strategist.maxLookAheadDepth = 100
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.name = "Background"
        self.addChild(background)
        
        board.position.y = -80
        board.zPosition = 1
        self.addChild(board)
        
        let node = SKSpriteNode(color: NSColor.green, size: CGSize(width: 150, height: 50))
        node.name = "button"
        node.position.x = 100
        node.position.y = 100
        self.addChild(node)
        
        let resetNode = SKSpriteNode(color: NSColor.red, size: CGSize(width: 150, height: 50))
        resetNode.name = "reset"
        resetNode.position.x = -100
        resetNode.position.y = 100
        self.addChild(resetNode)
        
        resetBoard()
    }
    
    func resetBoard() {
        
        currentChips.removeAll()
        
        board.reset()
        
        self.strategist.gameModel = board.gameModel
        
        state = .playing

    }
    
    func isWinner() -> Bool {
        if board.gameModel.isWin(for: board.gameModel.currentPlayer) {
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
        
        self.board.boxes[index].removeAll { (chip) -> Bool in
            return currentChips.contains(chip)
        }
        board.gameModel.removeChips(currentChips.count, inColumn: index)
        
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
            self.board.gameModel.currentPlayer = self.board.gameModel.currentPlayer.opponent
            
            DispatchQueue.global(qos: .default).async {
                let aiMove : AAPLMove = self.strategist.bestMove(for: self.board.gameModel.currentPlayer) as! AAPLMove
                
                for index in 0..<aiMove.chipsCount {
                    self.currentChips.append(self.board.boxes[aiMove.column][index])
                }
                
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                    if self.removeSelectedChipsAndEvaluateWinner() {
                        print("Machine WON!")
                        self.state = .ended
                        return
                    }
                    self.board.gameModel.currentPlayer = self.board.gameModel.currentPlayer.opponent
                    self.state = .playing
                })
                
            }
            
            return
        }
        
        if state != .playing { return }
        
        if let box = self.nodes(at: pos).first(where: { $0.name == "coin"}) as? Chip {
            if currentChips.contains(box) { return }
            if box.boxIndex != currentChips.first?.boxIndex {
                for currentChip in currentChips {
                    currentChip.alpha = 1.0
                }
                currentChips.removeAll()
            }
            box.alpha = 0.4
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
