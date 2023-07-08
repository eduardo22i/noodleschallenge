//
//  GameScene.swift
//  Tea Challenge Mac
//
//  Created by Eduardo Irias on 12/19/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol GameSceneProtocol {
    var state: GameState { get }
    var strategist: GKMinmaxStrategist { get }

    var board: Board { get }
    var enemy: Enemy { get }
    var currentChips: [any Chip] { get }

//    var continueButton: SKSpriteNode!
//    var resetButton: SKSpriteNode!

    var dialogNode: DialogProtocol! { get }

    
    func addToCurrentSelected(coin: Chip)
}

class GameScene: SKScene, GameSceneProtocol {

    static let config = [4,3,2]

    var state = GameState.playing {
        didSet {
            switch state {
            case .thinking:
                self.continueButton.alpha = 0.4
                self.continueButton.isHidden = false
                self.resetButton.isHidden = false
                dialogNode.hideDialog()
            case .playing:
                self.continueButton.alpha = 1.0
                self.continueButton.isHidden = false
                self.resetButton.isHidden = false
                dialogNode.hideDialog()
            case .ended:
                self.continueButton.alpha = 1.0
                self.continueButton.isHidden = true
                self.resetButton.isHidden = false
                dialogNode.hideDialog()
            case .dialog:
                self.continueButton.isHidden = true
                self.resetButton.isHidden = true
                dialogNode.showDialog()
            }
        }
    }
    let strategist = GKMinmaxStrategist()
    
    let board: Board = BoardSK(config: GameScene.config)
    var dialogNode: DialogProtocol!

    var enemy: Enemy = EnemySK(name: "Obinoby")

    var continueButton: SKSpriteNode!
    var resetButton: SKSpriteNode!
    
    var currentChips: [any Chip] = [ChipSK]()
    
    var isScrollingInput = false
    private var spinnyNode : SKShapeNode?
    private var lastUpdateTime : TimeInterval = 0
    
    // MARK: - Scene
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        self.strategist.maxLookAheadDepth = 100
        
        dialogNode = self.childNode(withName: "dialog") as? DialogSKNode
        continueButton = self.childNode(withName: "continueButton") as? SKSpriteNode
        resetButton = self.childNode(withName: "resetButton") as? SKSpriteNode

        if let enemy = enemy as? EnemySK {
            enemy.position.y = self.size.height / 2.0 - enemy.size.height / 2.0 + 20
            enemy.zPosition = 1
            self.addChild(enemy)
        }

        if let board = board as? BoardSK {
            board.position.y = -100
            board.zPosition = 2
            self.addChild(board)
        }
        
        resetBoard()
        
        self.state = .dialog
        dialogNode.resetDialog()
        renderDialog()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if isScrollingInput {
            let w = (self.size.width + self.size.height) * 0.05
            self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
            
            if let spinnyNode = self.spinnyNode {
                spinnyNode.lineWidth = 2.5
                
                spinnyNode.zPosition = 100
                self.addChild(spinnyNode)
            }
        }
    }
    
    // MARK: - Logic
    
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
        board.remove(chips: currentChips)
        currentChips.removeAll()
    }
    
    func removeSelectedChipsAndEvaluateWinner() -> Bool {
        removeSelectedChips()
        return isWinner()
    }
    
    func addToCurrentSelected(coin: any Chip) {
        if enemy.state != .waiting {
            enemy.wait()
        }

        if currentChips.contains (where: { $0.index == coin.index}) {
            coin.isSelected = false
            currentChips.removeAll(where: { $0.index == coin.index})
            return
        }

        if coin.boxIndex != currentChips.first?.boxIndex {
            for currentChip in currentChips {
                currentChip.isSelected = false
            }
            currentChips.removeAll()
        }
        
        coin.isSelected = true
        currentChips.append(coin)
    }
    
    // MARK: - Touch Events
    
    func touchDown(atPoint pos : CGPoint) {
        if let continueButton = self.nodes(at: pos).first(where: { $0.name == "continueButton"}) {
            continueButton.alpha = 0.2
        }
        
        if let resetButton = self.nodes(at: pos).first(where: { $0.name == "resetButton"}) {
            resetButton.alpha = 0.2
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if self.state == .dialog {
            switch dialogNode.state {
            case .thinking:
                state = .playing
            case .waiting:
                aiPlay()
            case .celebrating, .crying:
                state = .ended
            case .instructions, .wakeUp:
                dialogNode.nextDialogInQueue()
                renderDialog()
            }
            return
        }
        
        continueButton.alpha = 1.0
        resetButton.alpha = 1.0
        
        if let _ = self.nodes(at: pos).first(where: { $0.name == "resetButton"}) {
            enemy.state = .waiting
            resetBoard()
        }
        
        if state == .thinking { return }
        
        if let _ = self.nodes(at: pos).first(where: { $0.name == "continueButton"}), !currentChips.isEmpty {
            
            self.state = .dialog
            
            if self.removeSelectedChipsAndEvaluateWinner() {
                self.dialogNode.state = .crying
                self.enemy.state = .crying
            } else {
                
                var chipCount = 0
                for box in board.boxes {
                    for _ in box.chips {
                        chipCount += 1
                    }
                }
                if chipCount == 0 {
                    dialogNode.state = .celebrating
                    self.enemy.state = .celebrating
                } else {
                    dialogNode.state = .waiting
                }
            }

            dialogNode.setRandomDialogFromState()
            self.renderDialog()
            
        }
        
        if state != .playing { return }
        
        if let chip = self.nodes(at: pos).first(where: { $0.name == "coin"}) as? ChipSK {
            self.addToCurrentSelected(coin: chip)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        self.spinnyNode?.position = pos
    }
    
    
    // MARK: - Targets
    
    // MARK: iOS
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
    
    // MARK: tvOS
    #elseif os(tvOS)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    // MARK: macOS
    #else
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    #endif
    
    // MARK: - AI
    
    func aiPlay() {
        
        state = .thinking
        
        board.gameModel.currentPlayer = self.board.gameModel.currentPlayer.opponent
        enemy.state = .thinking
        
        DispatchQueue.global(qos: .default).async {
            let aiMove : AAPLMove = self.strategist.bestMove(for: self.board.gameModel.currentPlayer) as! AAPLMove
            
            for index in 0..<aiMove.chipsCount {
                self.currentChips.append(self.board.boxes[aiMove.column].chips[index])
            }
            
            let deadlineTime = DispatchTime.now() + .seconds(2)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: DispatchWorkItem(block: {

                for currentChip in self.currentChips {
                    currentChip.isSelected = true
                }
                
                if self.removeSelectedChipsAndEvaluateWinner() {
                    
                    self.dialogNode.state = .celebrating
                    self.dialogNode.setRandomDialogFromState()
                    self.renderDialog()
                    
                    self.enemy.state = .celebrating
                    
                    self.state = .dialog
                    return
                }
                
                
                self.board.gameModel.currentPlayer = self.board.gameModel.currentPlayer.opponent
                
                self.dialogNode.state = .thinking
                self.dialogNode.setRandomDialogFromState()
                self.renderDialog()
                self.state = .dialog
                self.enemy.state = .waiting

            }))
        }
    }
    
    // MARK: - Update
    
    func renderDialog() {
        dialogNode.render()

        if dialogNode.state == .wakeUp {
            if enemy.state == .sleeping && dialogNode.currentDialogIndex > 0 {
                enemy.wakeUp()
            }
            if dialogNode.currentDialogIndex == DialogState.wakeUp.texts.count - 1 {
                dialogNode.state = .instructions
                dialogNode.resetDialog()
            }
        }
        if dialogNode.state == .instructions && dialogNode.currentDialogIndex == DialogState.instructions.texts.count - 1 {
            state = .playing
            dialogNode.resetDialog()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (lastUpdateTime == 0) {
            lastUpdateTime = currentTime
        }

        
        lastUpdateTime = currentTime
    }
}
