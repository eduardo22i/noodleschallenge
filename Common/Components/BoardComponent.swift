//
//  BoardComponent.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 4/5/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

final class BoardComponent: Component {

    var gameModel: BoardGameModel!
    var boxes: [any BoxEntity] = []

    private var config = [Int]()

    init(config: [Int]) {
        self.config = config
        gameModel = BoardGameModel(chips: config)
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(strategist: inout GameModelStrategist) {
        strategist.gameModel = gameModel
    }

    func reset() {
        for box in boxes {
            box.boxComponent.chips.forEach({ (chip) in
                chip.renderableComponent.renderable.removeFromParent()
            })
            box.renderableComponent.renderable.removeFromParent()
        }
        boxes.removeAll()

        gameModel = BoardGameModel(chips: config)

        for (index, chipsCount) in self.config.enumerated() {

            guard let boxView = entity?.component(ofType: RenderableComponent<any BoardView>.self)?.renderable.addBox(index: index) else {
                continue
            }
            let box = Box()
            box.addComponent(BoxComponent(index: index))
            box.addComponent(RenderableComponent<any BoxView>(renderable: boxView))
            box.boxComponent.addCoins(count: chipsCount)
            boxes.append(box)
        }
    }

    func switchPlayer() {
        gameModel.currentPlayer = gameModel.currentPlayer.opponent
    }

    func remove(chips: [any ChipEntity]) {
        guard let index = chips.first?.chipComponent.boxIndex else { return }

        boxes[index].boxComponent.remove(chips: chips)
        gameModel.removeChips(chips.count, inColumn: index)
    }

    func isWinForCurrentPlayer() -> Bool {
        gameModel.isWin(for: gameModel.currentPlayer)
    }
}
