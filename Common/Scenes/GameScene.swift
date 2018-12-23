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
    static let config = [4,2,3]
    
    var state = GameState.playing
    let strategist = GKMinmaxStrategist()
    
    let board = Board(config: GameScene.config)

    let enemy = Enemy(name: "Obinoby")
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var continueButton: SKSpriteNode!
    var resetButton: SKSpriteNode!
    
    var currentChips = [Chip]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        self.strategist.maxLookAheadDepth = 100
        
        continueButton = self.childNode(withName: "continueButton") as? SKSpriteNode
        resetButton = self.childNode(withName: "resetButton") as? SKSpriteNode
        
        enemy.position.y = self.size.height / 2.0 - enemy.size.height / 2.0 + 20
        enemy.zPosition = 1
        self.addChild(enemy)
        
        enemy.wakeUp()
        
        board.position.y = -100
        board.zPosition = 2
        self.addChild(board)
        
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
            return true
        }
        return false
    }
    
    func removeSelectedChips() {
        self.board.remove(chips: currentChips)
        currentChips.removeAll()
    }
    
    func removeSelectedChipsAndEvaluateWinner() -> Bool {
        removeSelectedChips()
        return isWinner()
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let continueButton = self.nodes(at: pos).first(where: { $0.name == "continueButton"}) {
            continueButton.alpha = 0.2
        }
        
        if let resetButton = self.nodes(at: pos).first(where: { $0.name == "resetButton"}) {
            resetButton.alpha = 0.2
        }
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        continueButton.alpha = 1.0
        resetButton.alpha = 1.0
        
        if let _ = self.nodes(at: pos).first(where: { $0.name == "resetButton"}) {
            self.resetBoard()
        }
        
        if state == .thinking { return }
        
        if let _ = self.nodes(at: pos).first(where: { $0.name == "continueButton"}) {
            self.state = .thinking
            if self.removeSelectedChipsAndEvaluateWinner() {
                print("You WON!")
                self.state = .ended
                self.enemy.state = .crying
                return
            }
            self.board.gameModel.currentPlayer = self.board.gameModel.currentPlayer.opponent
            enemy.state = .thinking
            
            DispatchQueue.global(qos: .default).async {
                let aiMove : AAPLMove = self.strategist.bestMove(for: self.board.gameModel.currentPlayer) as! AAPLMove
                
                for index in 0..<aiMove.chipsCount {
                    self.currentChips.append(self.board.boxes[aiMove.column].chips[index])
                }
                
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                    if self.removeSelectedChipsAndEvaluateWinner() {
                        print("Machine WON!")
                        self.state = .ended
                        self.enemy.state = .celebrating
                        return
                    }
                    self.board.gameModel.currentPlayer = self.board.gameModel.currentPlayer.opponent
                    self.state = .playing
                    self.enemy.state = .waiting
                })
                
            }
            
            return
        }
        
        if state != .playing { return }
        
        if enemy.state != .waiting {
            enemy.wait()
        }  
        
        if let chip = self.nodes(at: pos).first(where: { $0.name == "coin"}) as? Chip {
            
            if currentChips.contains(chip) {
                chip.isSelected = false
                currentChips.removeAll(where: { $0 == chip})
                return
            }
            
            if chip.boxIndex != currentChips.first?.boxIndex {
                for currentChip in currentChips {
                    currentChip.isSelected = false
                }
                currentChips.removeAll()
            }
            
            chip.isSelected = true
            currentChips.append(chip)
        }
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    #else
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    #endif
    
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
