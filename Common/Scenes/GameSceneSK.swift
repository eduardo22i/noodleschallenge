//
//  GameScene.swift
//  Tea Challenge Mac
//
//  Created by Eduardo Irias on 12/19/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol GameScene: AnyObject {
    var view: GameSceneView { get }

    var state: GameState { get }
    var strategist: GKMinmaxStrategist { get }

    var board: Board { get set }
    var enemy: Enemy { get set }
    var currentChips: [any Chip] { get }

    var dialogNode: (any Dialog)! { get set }

    func start()
    func addToCurrentSelected(coin: Chip)

    func pressResetButton()
    func pressContinueButton()
    func pressChip(chipView: ChipView)
    func pressScreen() -> Bool
}

final class GameSceneLogic: GameScene {
    static let config = [4,3,2]

    var view: GameSceneView

    var state = GameState.playing {
        didSet {
            switch state {
            case .thinking:
                view.disableContinueButton()
                dialogNode?.hideDialog()
            case .playing:
                view.showButtons()
                dialogNode?.hideDialog()
            case .ended:
                view.hideContinueButton()
                dialogNode?.hideDialog()
            case .dialog:
                view.hideButtons()
                dialogNode?.showDialog()
            }
        }
    }

    let strategist = GKMinmaxStrategist()

    var board: Board
    var enemy: Enemy

    var currentChips: [any Chip] = [Chip]()

    var dialogNode: (any Dialog)! = nil

    init(view: GameSceneView, state: GameState = GameState.playing, board: Board, enemy: Enemy) {
        self.view = view
        self.state = state
        self.board = board
        self.enemy = enemy

        self.view.addBoardView(board.view)
        self.view.addEnemyView(enemy.view)
        
        self.strategist.maxLookAheadDepth = 100
    }

    func start() {
        resetBoard()

        state = .dialog
        dialogNode.resetDialog()
        renderDialog()
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

    func removeSelectedChips() {
        board.remove(chips: currentChips)
        currentChips.removeAll()
    }

    private func isWinner() -> Bool {
        if board.gameModel.isWin(for: board.gameModel.currentPlayer) {
            return true
        }
        return false
    }

    func removeSelectedChipsAndEvaluateWinner() -> Bool {
        removeSelectedChips()
        return isWinner()
    }

    func pressResetButton() {
        enemy.state = .waiting
        resetBoard()
    }

    func pressContinueButton() {
        guard state != .thinking else { return }

        if !currentChips.isEmpty {

           state = .dialog

           if removeSelectedChipsAndEvaluateWinner() {
               dialogNode.state = .crying
               enemy.state = .crying
           } else {

               var chipCount = 0
               for box in board.boxes {
                   for _ in box.chips {
                       chipCount += 1
                   }
               }
               if chipCount == 0 {
                   dialogNode.state = .celebrating
                   enemy.state = .celebrating
               } else {
                   dialogNode.state = .waiting
               }
           }

           dialogNode.setRandomDialogFromState()
           renderDialog()

       }
    }

    func pressChip(chipView: ChipView) {
        guard state == .playing else {
            return
        }
        if let logic = chipView.logic {
            self.addToCurrentSelected(coin: logic)
        }
    }

    func pressScreen() -> Bool {
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
            return true
        }
        return false
    }

    func resetBoard() {
        currentChips.removeAll()
        board.reset()
        strategist.gameModel = board.gameModel
        state = .playing
    }

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
}

protocol GameSceneView: AnyObject {
    func addEnemyView(_ enemyView: EnemyView)
    func addBoardView(_ boardView: BoardView)

    func disableContinueButton()
    func hideContinueButton()
    func hideButtons()
    func showButtons()
}

class GameSceneSK: SKScene, GameSceneView {

    var logic: GameScene! {
        didSet {
            if let dialogSKNode = self.childNode(withName: "dialog") as? SKSpriteNode,
               let dialogNode = dialogSKNode as? (any DialogView) {
                logic.dialogNode = DialogLogic(view: dialogNode)
            }
        }
    }

    var continueButton: SKSpriteNode!
    var resetButton: SKSpriteNode!
    
    var isScrollingInput = false
    private var spinnyNode : SKShapeNode?
    private var lastUpdateTime : TimeInterval = 0
    
    // MARK: - Scene
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0

        continueButton = self.childNode(withName: "continueButton") as? SKSpriteNode
        resetButton = self.childNode(withName: "resetButton") as? SKSpriteNode
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
        guard !logic.pressScreen() else {
            return
        }
        
//        continueButton.alpha = 1.0
//        resetButton.alpha = 1.0
        
        if let _ = self.nodes(at: pos).first(where: { $0.name == "resetButton"}) {
          logic.pressResetButton()
        }

        if let _ = self.nodes(at: pos).first(where: { $0.name == "continueButton"}) {
            logic.pressContinueButton()
        }

        if let chip = self.nodes(at: pos).first(where: { $0.name == "coin"}) as? ChipSK {
            logic.pressChip(chipView: chip)
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

    
    // MARK: - Update

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (lastUpdateTime == 0) {
            lastUpdateTime = currentTime
        }

        
        lastUpdateTime = currentTime
    }

    func addEnemyView(_ enemyView: EnemyView) {
        if let enemy = enemyView as? EnemySK {
            enemy.position.y = self.size.height / 2.0 - enemy.size.height / 2.0 + 20
            enemy.zPosition = 1
            self.addChild(enemy)
        }
    }

    func addBoardView(_ boardView: BoardView) {
        if let board = boardView as? BoardSK {
            board.position.y = -100
            board.zPosition = 2
            self.addChild(board)
        }
    }

    func disableContinueButton() {
        continueButton.alpha = 0.4
        continueButton.isHidden = false
        resetButton.isHidden = false
    }

    func hideContinueButton() {
        self.continueButton.alpha = 1.0
        self.continueButton.isHidden = true
        self.resetButton.isHidden = false
    }

    func hideButtons() {
        self.continueButton.isHidden = true
        self.resetButton.isHidden = true
    }

    func showButtons() {
        self.continueButton.alpha = 1.0
        self.resetButton.alpha = 1.0

        self.continueButton.isHidden = false
        self.resetButton.isHidden = false
    }
}
