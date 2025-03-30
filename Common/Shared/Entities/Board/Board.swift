//
//  Board.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation
import GameplayKit

extension GKMinmaxStrategist: NCStrategy { }
protocol NCStrategy: AnyObject {
    var maxLookAheadDepth: Int { get set }
    var gameModel: (any GKGameModel)? { get set }
    func bestMoveForActivePlayer() -> (any GKGameModelUpdate)?
}

protocol BoardProtocol {

    var view: any BoardView { get set }

    var currentPlayer: NCPlayer { get }
    var boxes: [any Box] { get }

    func set(strategist: inout NCStrategy)

    func reset()
    func switchPlayer()
    func remove(chips: [any Chip])

    func isWinForCurrentPlayer() -> Bool
}

final class Board: BoardProtocol {

    var view: any BoardView

    var gameModel: NCBoard!
    var currentPlayer: NCPlayer {
        gameModel.currentPlayer
    }
    var boxes: [any Box] = []

    private var config = [Int]() {
        didSet {
            gameModel = NCBoard(chips: config)
        }
    }

    init(view: any BoardView, config: [Int]) {
        self.view = view
        self.config = config
    }

    // MARK: Functions

    func set(strategist: inout NCStrategy) {
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

        gameModel = NCBoard(chips: config)

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

protocol BoardView: AnyObject {
    func addBox(index: Int) -> any BoxView
}
