//
//  BoardLogic.swift
//  Noodles Challenge
//
//  Created by Eduardo Irias on 3/4/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation
import GameplayKit

class BoardGameModel: NSObject {

    var currentPlayer: Player
    static let width = 3
    static let height = 1
    static let countToWin = 1

    private(set) var cells: [Int]

    init(chips: [Int]) {
        self.cells = chips
        self.currentPlayer = Player.humanPlayer
    }

    func updateChips(from otherBoard: BoardGameModel) {
        self.cells = otherBoard.cells
    }

    func chipsInColumn(_ column: Int, row: Int) -> Int {
        return cells[row + column]
    }

    func removeChips(_ count: Int, inColumn column: Int) {
        self.cells[column] -= count
    }

    func canRemoveChips(_ count: Int, inColumn column: Int) -> Bool {
        return cells[column] >= count
    }

    func isFull() -> Bool {
        for column in 0..<BoardGameModel.width {
            if self.canRemoveChips(1, inColumn: column) {
                return false
            }
        }
        return true
    }

    func runCounts(for player: Player) -> [Int] {
        var counts: [Int] = []
        var totalRunCount = 0

        for column in 0..<BoardGameModel.width {
            totalRunCount += chipsInColumn(column, row: 0)
        }

        for column in (0..<BoardGameModel.width).reversed() {
            let chipsCount = self.chipsInColumn(column, row: 0)
            for colCount in (1...chipsCount).reversed() {
                if (totalRunCount - colCount) == 1 {
                    counts.append(colCount)
                }
            }
        }

        return counts
    }

}
