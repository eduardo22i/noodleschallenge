//
//  GameSceneController.swift
//  Tea Challenge Mac
//
//  Created by Eduardo Irias on 12/19/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation
import GameplayKit

protocol GameScene: AnyObject {
    var view: GameSceneView { get }

    var state: GameState { get }
    var strategist: any GameModelStrategist { get }

    var board: Board { get set }
    var enemy: EnemyEntity { get set }
    var currentChips: [any ChipEntity] { get }

    var dialogNode: Dialog { get set }

    func start()
    func addToCurrentSelected(coin: ChipEntity)

    func pressResetButton()
    func pressContinueButton()
    func press(chip: ChipEntity)
    func pressScreen() -> Bool
}

final class GameSceneController: GameScene {
    static let config = [4,3,2]

    var view: GameSceneView

    var state = GameState.playing {
        didSet {
            switch state {
            case .thinking:
                view.disableContinueButton()
                dialogNode.dialogComponent.hideDialog()
            case .playing:
                view.showButtons()
                dialogNode.dialogComponent.hideDialog()
            case .ended:
                view.hideContinueButton()
                dialogNode.dialogComponent.hideDialog()
            case .dialog:
                view.hideButtons()
                dialogNode.dialogComponent.showDialog()
            }
        }
    }

    var strategist: any GameModelStrategist = GKMinmaxStrategist()

    var board: Board
    var enemy: EnemyEntity

    var currentChips: [any ChipEntity] = [ChipEntity]()

    var dialogNode: Dialog = Dialog()

    init(view: GameSceneView, state: GameState = GameState.playing, board: Board, enemy: EnemyEntity) {
        self.view = view
        self.state = state
        self.board = board
        self.enemy = enemy

        self.view.addBoardView(board.renderableComponent)
        self.view.addEnemyView(enemy.renderableComponent)

        view.logic = self

        self.strategist.maxLookAheadDepth = 100
    }

    func start() {
        resetBoard()

        state = .dialog
        dialogNode.dialogComponent.resetDialog()
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
            dialogNode.dialogComponent.state = .crying
            enemy.enemyComponent.state = .crying
        } else {

            var chipCount = 0
            for box in board.gameModel.boxes {
                for _ in box.boxComponent.chips {
                    chipCount += 1
                }
            }
            if chipCount == 0 {
                dialogNode.dialogComponent.state = .celebrating
                enemy.enemyComponent.state = .celebrating
            } else {
                dialogNode.dialogComponent.state = .waiting
            }
        }

        dialogNode.dialogComponent.setRandomDialogFromState()
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
            switch dialogNode.dialogComponent.state {
            case .thinking:
                state = .playing
            case .waiting:
                aiPlay()
            case .celebrating, .crying:
                state = .ended
            case .instructions, .wakeUp:
                dialogNode.dialogComponent.nextDialogInQueue()
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

                    self.dialogNode.dialogComponent.state = .celebrating
                    self.dialogNode.dialogComponent.setRandomDialogFromState()
                    self.renderDialog()

                    self.enemy.enemyComponent.state = .celebrating

                    self.state = .dialog
                    return
                }


                self.board.gameModel.switchPlayer()

                self.dialogNode.dialogComponent.state = .thinking
                self.dialogNode.dialogComponent.setRandomDialogFromState()
                self.renderDialog()
                self.state = .dialog
                self.enemy.enemyComponent.state = .waiting

            }))
        }
    }

    // MARK: - Update

    func renderDialog() {
        dialogNode.dialogComponent.render()

        if dialogNode.dialogComponent.state == .wakeUp {
            if enemy.enemyComponent.state == .sleeping && dialogNode.dialogComponent.currentDialogIndex > 0 {
                enemy.enemyComponent.wakeUp()
            }
            if dialogNode.dialogComponent.currentDialogIndex == DialogState.wakeUp.texts.count - 1 {
                dialogNode.dialogComponent.state = .instructions
                dialogNode.dialogComponent.resetDialog()
            }
        }
        if dialogNode.dialogComponent.state == .instructions && dialogNode.dialogComponent.currentDialogIndex == DialogState.instructions.texts.count - 1 {
            state = .playing
            dialogNode.dialogComponent.resetDialog()
        }
    }
}
