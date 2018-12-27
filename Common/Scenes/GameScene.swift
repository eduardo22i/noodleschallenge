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
    static let config = [4,3,2]
    
    var state = GameState.playing {
        didSet {
            switch state {
            case .thinking:
                self.continueButton.alpha = 0.4
                self.continueButton.isHidden = false
                self.resetButton.isHidden = false
                self.dialogNode.isHidden = true
            case .playing:
                self.continueButton.alpha = 1.0
                self.continueButton.isHidden = false
                self.resetButton.isHidden = false
                self.dialogNode.isHidden = true
            case .ended:
                self.continueButton.alpha = 1.0
                self.continueButton.isHidden = true
                self.resetButton.isHidden = false
                self.dialogNode.isHidden = true
            case .dialog:
                self.continueButton.isHidden = true
                self.resetButton.isHidden = true
                self.dialogNode.isHidden = false
            }
        }
    }
    let strategist = GKMinmaxStrategist()
    
    let board = Board(config: GameScene.config)
    var dialogNode: Dialog!

    let enemy = Enemy(name: "Obinoby")
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var continueButton: SKSpriteNode!
    var resetButton: SKSpriteNode!
    
    var currentChips = [Chip]()
    
    var currentDialogIndex = 0
    
    var isScrollingInput = false
    private var lastUpdateTime : TimeInterval = 0
    
    // MARK: - Scene
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        self.strategist.maxLookAheadDepth = 100
        
        dialogNode = self.childNode(withName: "dialog") as? Dialog
        continueButton = self.childNode(withName: "continueButton") as? SKSpriteNode
        resetButton = self.childNode(withName: "resetButton") as? SKSpriteNode
        
        enemy.position.y = self.size.height / 2.0 - enemy.size.height / 2.0 + 20
        enemy.zPosition = 1
        self.addChild(enemy)
        
        board.position.y = -100
        board.zPosition = 2
        self.addChild(board)
        
        resetBoard()
        
        self.state = .dialog
        currentDialogIndex = 0
        renderDialog()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if isScrollingInput {
            let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipe))
            swipeRecognizer.direction = .right
            self.view!.addGestureRecognizer(swipeRecognizer)
            
            let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipe))
            leftSwipeRecognizer.direction = .left
            self.view!.addGestureRecognizer(leftSwipeRecognizer)
            
            let downSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipe))
            downSwipeRecognizer.direction = .down
            self.view!.addGestureRecognizer(downSwipeRecognizer)
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameScene.tap(_:)))
            self.view!.addGestureRecognizer(tapRecognizer)
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
        self.board.remove(chips: currentChips)
        currentChips.removeAll()
    }
    
    func removeSelectedChipsAndEvaluateWinner() -> Bool {
        removeSelectedChips()
        return isWinner()
    }
    
    func addToCurrentSelected(coin: Chip) {
        if enemy.state != .waiting {
            enemy.wait()
        }
        
        if currentChips.contains(coin) {
            coin.isSelected = false
            currentChips.removeAll(where: { $0 == coin})
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
            if dialogNode.state == .thinking {
                self.state = .playing
            } else if dialogNode.state == .waiting {
                self.aiPlay()
            } else if dialogNode.state == .celebrating || dialogNode.state == .crying {
                self.state = .ended
            } else {
                currentDialogIndex += 1
                renderDialog()
            }
            return
        }
        
        if isScrollingInput { return }
        
        continueButton.alpha = 1.0
        resetButton.alpha = 1.0
        
        if let _ = self.nodes(at: pos).first(where: { $0.name == "resetButton"}) {
            self.enemy.state = .waiting
            self.resetBoard()
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
                    self.dialogNode.state = .celebrating
                    self.enemy.state = .celebrating
                } else {
                    self.dialogNode.state = .waiting
                }
            }
            self.currentDialogIndex = Int.random(in: 0..<self.dialogNode.state.texts.count)
            self.renderDialog()
            
        }
        
        if state != .playing { return }
        
        if let chip = self.nodes(at: pos).first(where: { $0.name == "coin"}) as? Chip {
            self.addToCurrentSelected(coin: chip)
        }
    }
    
    // MARk: Swie
    @objc func tap(_ sender: Any?) {
        if isBottonNavigationSelected {
            
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
                    self.dialogNode.state = .celebrating
                    self.enemy.state = .celebrating
                } else {
                    self.dialogNode.state = .waiting
                }
            }
            self.currentDialogIndex = Int.random(in: 0..<self.dialogNode.state.texts.count)
            self.renderDialog()
            
        } else {
            if let currentTVSelectedChip = currentTVSelectedChip {
                self.addToCurrentSelected(coin: currentTVSelectedChip)
            }
        }
    }
    
    @objc func swipe(_ sender: Any?) {
        if state != .playing { return }
        
        guard let gesture = sender as? UISwipeGestureRecognizer else { return }
        
        currentTVSelectedChip?.setScale(1.0)
        
        if isBottonNavigationSelected && (gesture.direction == .right || gesture.direction == .left) {
            continueButton.setScale(1.0)
        }
        
        if gesture.direction == .down {
            isBottonNavigationSelected = true
            continueButton.setScale(1.4)
            return
        }
        
        if gesture.direction == .right {
            currentChipIndex += 1
        }else {
            currentChipIndex -= 1
        }
        
        if currentChipIndex == board.boxes[currentBoxIndex].chips.count {
            currentBoxIndex += 1
            currentChipIndex = 0
        } else if currentChipIndex == -1 {
            currentBoxIndex -= 1
            if currentBoxIndex >= 0 {
                currentChipIndex = board.boxes[currentBoxIndex].chips.count - 1
            }
        }
        
        if currentBoxIndex == board.boxes.count {
            currentBoxIndex = 0
            currentChipIndex = 0
        } else if currentBoxIndex == -1 {
            currentBoxIndex = board.boxes.count - 1
            currentChipIndex = board.boxes[currentBoxIndex].chips.count - 1
        }
        if board.boxes[currentBoxIndex].chips.count >= currentChipIndex {
            currentTVSelectedChip = board.boxes[currentBoxIndex].chips[currentChipIndex]
        }
        currentTVSelectedChip?.setScale(1.4)

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
    
    var currentBoxIndex = 0
    var currentChipIndex = 0
    var isBottonNavigationSelected = false
    var currentTVSelectedChip: Chip?
    
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
        //for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//
//        let w = (self.size.width + self.size.height) * 0.05
//        let spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//
//        spinnyNode.lineWidth = 2.5
//
//        spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//        spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                          SKAction.fadeOut(withDuration: 0.5),
//                                          SKAction.removeFromParent()]))
//
//        spinnyNode.position = touches.first!.location(in: self)
//        spinnyNode.zPosition = 100
//        self.addChild(spinnyNode)
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
        
        self.state = .thinking
        
        self.board.gameModel.currentPlayer = self.board.gameModel.currentPlayer.opponent
        enemy.state = .thinking
        
        DispatchQueue.global(qos: .default).async {
            let aiMove : AAPLMove = self.strategist.bestMove(for: self.board.gameModel.currentPlayer) as! AAPLMove
            
            for index in 0..<aiMove.chipsCount {
                self.currentChips.append(self.board.boxes[aiMove.column].chips[index])
            }
            
            let deadlineTime = DispatchTime.now() + .seconds(2)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                
                for currentChip in self.currentChips {
                    currentChip.isSelected = true
                }
                
                if self.removeSelectedChipsAndEvaluateWinner() {
                    
                    self.dialogNode.state = .celebrating
                    self.currentDialogIndex = Int.random(in: 0..<self.dialogNode.state.texts.count)
                    self.renderDialog()
                    
                    self.enemy.state = .celebrating
                    
                    self.state = .dialog
                    return
                }
                
                
                self.board.gameModel.currentPlayer = self.board.gameModel.currentPlayer.opponent
                
                self.dialogNode.state = .thinking
                self.currentDialogIndex = Int.random(in: 0..<self.dialogNode.state.texts.count)
                self.renderDialog()
                self.state = .dialog
                self.enemy.state = .waiting
            })
            
        }
    }
    
    // MARK: - Update
    
    func renderDialog() {
        dialogNode?.text = dialogNode.state.texts[currentDialogIndex]

        if dialogNode.state == .wakeUp {
            if enemy.state == .sleeping && currentDialogIndex > 0 {
                enemy.wakeUp()
            }
            if currentDialogIndex == DialogState.wakeUp.texts.count - 1 {
                dialogNode.state = .instructions
                currentDialogIndex = -1
            }
        }
        if dialogNode.state == .instructions && currentDialogIndex == DialogState.instructions.texts.count - 1 {
            self.state = .playing
            currentDialogIndex = 0
        }
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
