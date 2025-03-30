//
//  GameScene.swift
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

    var board: BoardProtocol { get set }
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

    var strategist: any GameModelStrategist = GKMinmaxStrategist()

    var board: BoardProtocol
    var enemy: Enemy

    var currentChips: [any Chip] = [Chip]()

    var dialogNode: (any Dialog)! = nil

    init(view: GameSceneView, state: GameState = GameState.playing, board: BoardProtocol, enemy: Enemy) {
        self.view = view
        self.state = state
        self.board = board
        self.enemy = enemy

        self.view.addBoardView(board.view)
        self.view.addEnemyView(enemy.view)

        view.logic = self

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
        board.isWinForCurrentPlayer()
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
        guard state != .thinking,
        !currentChips.isEmpty else { return }

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
        board.set(strategist: &strategist)
        state = .playing
    }

    // MARK: - AI

    func aiPlay() {

        state = .thinking

        board.switchPlayer()
        enemy.state = .thinking

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

                    self.dialogNode.state = .celebrating
                    self.dialogNode.setRandomDialogFromState()
                    self.renderDialog()

                    self.enemy.state = .celebrating

                    self.state = .dialog
                    return
                }


                self.board.switchPlayer()

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
    var logic: GameScene? { get set }

    func addEnemyView(_ enemyView: EnemyView)
    func addBoardView(_ boardView: BoardView)

    func disableContinueButton()
    func hideContinueButton()
    func hideButtons()
    func showButtons()
}
