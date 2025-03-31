//
//  BoardController.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation

protocol BoardControllable {

    var view: any BoardView { get set }

    var boxes: [any BoxControllable] { get }

    func set(strategist: inout GameModelStrategist)

    func reset()
    func switchPlayer()
    func remove(chips: [any ChipControllable])

    func isWinForCurrentPlayer() -> Bool
}

final class BoardController: BoardControllable {

    var view: any BoardView

    var gameModel: BoardGameModel!
    var boxes: [any BoxControllable] = []

    private var config = [Int]() {
        didSet {
            gameModel = BoardGameModel(chips: config)
        }
    }

    init(view: any BoardView, config: [Int]) {
        self.view = view
        self.config = config
    }
}

// MARK: - BoardControllable
extension BoardController {
    func set(strategist: inout GameModelStrategist) {
        strategist.gameModel = gameModel
    }

    func reset() {
        for box in boxes {
            box.chips.forEach({ (chip) in
                chip.view.removeFromParent()
            })
            box.view.removeFromParent()
        }
        boxes.removeAll()

        gameModel = BoardGameModel(chips: config)

        for (index, chipsCount) in self.config.enumerated() {

            let boxView = view.addBox(index: index)
            let box = BoxController(view: boxView, index: index)
            box.addCoins(count: chipsCount)
            boxes.append(box)
        }
    }

    func switchPlayer() {
        gameModel.currentPlayer = gameModel.currentPlayer.opponent
    }
    
    func remove(chips: [any ChipControllable]) {
        guard let index = chips.first?.boxIndex else { return }

        boxes[index].remove(chips: chips)
        gameModel.removeChips(chips.count, inColumn: index)
    }

    func isWinForCurrentPlayer() -> Bool {
        gameModel.isWin(for: gameModel.currentPlayer)
    }
}
