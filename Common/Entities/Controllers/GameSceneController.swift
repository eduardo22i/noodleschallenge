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

    var board: BoardControllable { get set }
    var enemy: EnemyEntity { get set }
    var currentChips: [any ChipControllable] { get }

    var dialogNode: Dialog { get set }

    func start()
    func addToCurrentSelected(coin: ChipControllable)

    func pressResetButton()
    func pressContinueButton()
    func press(chip: ChipControllable)
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

    var board: BoardControllable
    var enemy: EnemyEntity

    var currentChips: [any ChipControllable] = [ChipControllable]()

    var dialogNode: Dialog = Dialog()

    init(view: GameSceneView, state: GameState = GameState.playing, board: BoardControllable, enemy: EnemyEntity) {
        self.view = view
        self.state = state
        self.board = board
        self.enemy = enemy

        self.view.addBoardView(board.view)
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

    func addToCurrentSelected(coin: any ChipControllable) {
        if enemy.enemyComponent.state != .waiting {
            enemy.enemyComponent.wait()
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
        board.isWinForCurrentPlayer()
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
            for box in board.boxes {
                for _ in box.chips {
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

    func press(chip: ChipControllable) {
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
        board.reset()
        board.set(strategist: &strategist)
        state = .playing
    }

    // MARK: - AI

    func aiPlay() {

        state = .thinking

        board.switchPlayer()
        enemy.enemyComponent.state = .thinking

        DispatchQueue.global(qos: .default).async {
            guard let aiMove: NCMove = self.strategist.bestMoveForActivePlayer() as? NCMove else {
                return
            }

            for index in 0..<aiMove.chipsCount {
                self.currentChips.append(self.board.boxes[aiMove.column].chips[index])
            }

            let deadlineTime = DispatchTime.now() + .seconds(2)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: DispatchWorkItem(block: {

                for currentChip in self.currentChips {
                    currentChip.isSelected = true
                }

                if self.removeSelectedChipsAndEvaluateWinner() {

                    self.dialogNode.dialogComponent.state = .celebrating
                    self.dialogNode.dialogComponent.setRandomDialogFromState()
                    self.renderDialog()

                    self.enemy.enemyComponent.state = .celebrating

                    self.state = .dialog
                    return
                }


                self.board.switchPlayer()

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
