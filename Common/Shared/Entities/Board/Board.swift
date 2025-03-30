//
//  Board.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation

protocol BoardProtocol {

    var view: any BoardView { get set }

    var currentPlayer: Player { get }
    var boxes: [any Box] { get }

    func set(strategist: inout GameModelStrategist)

    func reset()
    func switchPlayer()
    func remove(chips: [any Chip])

    func isWinForCurrentPlayer() -> Bool
}

protocol BoardView: AnyObject {
    func addBox(index: Int) -> any BoxView
}

struct BoardSetup {
    let width = 3
    let height = 1
    let countToWin = 1
}

final class Board: BoardProtocol {

    var view: any BoardView

    var gameModel: BoardGameModel!
    var currentPlayer: Player {
        gameModel.currentPlayer
    }
    var boxes: [any Box] = []

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

// MARK: - BoardProtocol
extension Board {
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
            let box = BoxLogic(view: boxView, index: index)
            box.addCoins(count: chipsCount)
            boxes.append(box)
        }
    }

    func switchPlayer() {
        gameModel.currentPlayer = gameModel.currentPlayer.opponent
    }
    
    func remove(chips: [any Chip]) {
        guard let index = chips.first?.boxIndex else { return }

        boxes[index].remove(chips: chips)
        gameModel.removeChips(chips.count, inColumn: index)
    }

    func isWinForCurrentPlayer() -> Bool {
        gameModel.isWin(for: gameModel.currentPlayer)
    }
}
