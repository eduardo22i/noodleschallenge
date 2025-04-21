//
//  GameSceneComponent.swift
//  Tea Challenge Mac
//
//  Created by Eduardo Irias on 12/19/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation
import GameplayKit

protocol GameSceneEntity: Entity {
    var renderableComponent: RenderableComponent<any GameSceneView> { get }
}

protocol GameScene: AnyObject {
    var view: GameSceneView { get }

    var state: GameState { get }
    var strategist: any GameModelStrategist { get }

    var board: Board { get set }
    var enemy: EnemyEntity { get set }
    var currentChips: [any ChipEntity] { get }

    var dialog: Dialog { get set }

    func start()
    func addToCurrentSelected(coin: ChipEntity)

    func pressResetButton()
    func pressContinueButton()
    func press(chip: ChipEntity)
    func pressScreen() -> Bool
}

final class GameSceneComponent: Component, GameScene {
    static let config = [4,3,2]

    var view: GameSceneView {
        guard let component = entity?.component(ofType: RenderableComponent<any GameSceneView>.self) else {
            fatalError()
        }
        return component.renderable
    }

    var state = GameState.playing {
        didSet {
            switch state {
            case .thinking:
                view.disableContinueButton()
                dialog.dialogComponent.hideDialog()
            case .playing:
                view.showButtons()
                dialog.dialogComponent.hideDialog()
            case .ended:
                view.hideContinueButton()
                dialog.dialogComponent.hideDialog()
            case .dialog:
                view.hideButtons()
                dialog.dialogComponent.showDialog()
            }
        }
    }

    var strategist: any GameModelStrategist = GKMinmaxStrategist()

    var dialog: Dialog
    var board: Board
    var enemy: EnemyEntity

    var currentChips: [any ChipEntity] = [ChipEntity]()

    init(state: GameState = GameState.playing, dialog: Dialog, board: Board, enemy: EnemyEntity) {
        self.state = state
        self.dialog = dialog
        self.board = board
        self.enemy = enemy

        self.strategist.maxLookAheadDepth = 100
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        resetBoard()

        state = .dialog
        dialog.dialogComponent.resetDialog()
        renderDialog()
    }

    func addToCurrentSelected(coin: any ChipEntity) {
        if enemy.enemyComponent.state != .waiting {
            enemy.enemyComponent.wait()
        }

        if currentChips.contains (where: { $0.chipComponent.index == coin.chipComponent.index}) {
            coin.chipComponent.isSelected = false
            coin.renderableComponent.renderable.setSelected(status: false)

            currentChips.removeAll(where: { $0.chipComponent.index == coin.chipComponent.index})
            return
        }

        if coin.chipComponent.boxIndex != currentChips.first?.chipComponent.boxIndex {
            for currentChip in currentChips {
                currentChip.chipComponent.isSelected = false
                currentChip.renderableComponent.renderable.setSelected(status: false)
            }
            currentChips.removeAll()
        }

        coin.chipComponent.isSelected = true
        coin.renderableComponent.renderable.setSelected(status: true)
        currentChips.append(coin)
    }

    func removeSelectedChips() {
        board.gameModel.remove(chips: currentChips)
        currentChips.removeAll()
    }

    private func isWinner() -> Bool {
        board.gameModel.isWinForCurrentPlayer()
    }

    func removeSelectedChipsAndEvaluateWinner() -> Bool {
        removeSelectedChips()
        return isWinner()
    }

    func pressResetButton() {
        enemy.enemyComponent.state = .waiting
        resetBoard()
    }

    func pressContinueButton() {
        guard state != .thinking,
        !currentChips.isEmpty else { return }

        state = .dialog

        if removeSelectedChipsAndEvaluateWinner() {
            dialog.dialogComponent.state = .crying
            enemy.enemyComponent.state = .crying
        } else {

            var chipCount = 0
            for box in board.gameModel.boxes {
                for _ in box.boxComponent.chips {
                    chipCount += 1
                }
            }
            if chipCount == 0 {
                dialog.dialogComponent.state = .celebrating
                enemy.enemyComponent.state = .celebrating
            } else {
                dialog.dialogComponent.state = .waiting
            }
        }

        dialog.dialogComponent.setRandomDialogFromState()
        renderDialog()
    }

    func press(chip: ChipEntity) {
        guard state == .playing else {
            return
        }
        self.addToCurrentSelected(coin: chip)
    }

    func pressScreen() -> Bool {
        if self.state == .dialog {
            switch dialog.dialogComponent.state {
            case .thinking:
                state = .playing
            case .waiting:
                aiPlay()
            case .celebrating, .crying:
                state = .ended
            case .instructions, .wakeUp:
                dialog.dialogComponent.nextDialogInQueue()
                renderDialog()
            }
            return true
        }
        return false
    }

    func resetBoard() {
        currentChips.removeAll()
        board.gameModel.reset()
        board.gameModel.set(strategist: &strategist)
        state = .playing
    }

    // MARK: - AI

    func aiPlay() {

        state = .thinking

        board.gameModel.switchPlayer()
        enemy.enemyComponent.state = .thinking

        DispatchQueue.global(qos: .default).async {
            guard let aiMove: NCMove = self.strategist.bestMoveForActivePlayer() as? NCMove else {
                return
            }

            for index in 0..<aiMove.chipsCount {
                self.currentChips.append(self.board.gameModel.boxes[aiMove.column].boxComponent.chips[index])
            }

            let deadlineTime = DispatchTime.now() + .seconds(2)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: DispatchWorkItem(block: {

                for currentChip in self.currentChips {
                    currentChip.chipComponent.isSelected = true
                    currentChip.renderableComponent.renderable.setSelected(status: true)
                }

                if self.removeSelectedChipsAndEvaluateWinner() {

                    self.dialog.dialogComponent.state = .celebrating
                    self.dialog.dialogComponent.setRandomDialogFromState()
                    self.renderDialog()

                    self.enemy.enemyComponent.state = .celebrating

                    self.state = .dialog
                    return
                }


                self.board.gameModel.switchPlayer()

                self.dialog.dialogComponent.state = .thinking
                self.dialog.dialogComponent.setRandomDialogFromState()
                self.renderDialog()
                self.state = .dialog
                self.enemy.enemyComponent.state = .waiting

            }))
        }
    }

    // MARK: - Update

    func renderDialog() {
        dialog.dialogComponent.render()

        if dialog.dialogComponent.state == .wakeUp {
            if enemy.enemyComponent.state == .sleeping && dialog.dialogComponent.currentDialogIndex > 0 {
                enemy.enemyComponent.wakeUp()
            }
            if dialog.dialogComponent.currentDialogIndex == DialogState.wakeUp.texts.count - 1 {
                dialog.dialogComponent.state = .instructions
                dialog.dialogComponent.resetDialog()
            }
        }
        if dialog.dialogComponent.state == .instructions && dialog.dialogComponent.currentDialogIndex == DialogState.instructions.texts.count - 1 {
            state = .playing
            dialog.dialogComponent.resetDialog()
        }
    }
}
