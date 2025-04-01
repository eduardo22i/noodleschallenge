//
//  GameSceneSK.swift
//  Noodles Challenge iOS
//
//  Created by Eduardo Irias on 7/11/23.
//  Copyright © 2023 Estamp. All rights reserved.
//

import SpriteKit

final class GameSceneSK: SKScene, GameSceneView {

    var logic: GameScene? {
        didSet {
            if let dialogSKNode = self.childNode(withName: "dialog") as? DialogSKNode {
                logic?.dialogNode.addComponent(DialogRenderableComponent(renderable: dialogSKNode))
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
        guard logic?.pressScreen() == false else {
            return
        }

        continueButton.alpha = 1.0
        resetButton.alpha = 1.0

        if let _ = self.nodes(at: pos).first(where: { $0.name == "resetButton"}) {
          logic?.pressResetButton()
        }

        if let _ = self.nodes(at: pos).first(where: { $0.name == "continueButton"}) {
            logic?.pressContinueButton()
        }

        if let chipView = self.nodes(at: pos).first(where: { $0.name == "coin"}) as? ChipSK,
           let chip = chipView.chip {
            logic?.press(chip: chip)
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
