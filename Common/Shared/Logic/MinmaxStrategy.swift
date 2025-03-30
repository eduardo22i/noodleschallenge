//
//  MinmaxStrategy.swift
//  Noodles Challenge
//
//  Created by Eduardo Irias on 3/4/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation
import GameplayKit

class NCMove: NSObject, GKGameModelUpdate {
    var value: Int = 0
    
    var column: Int
    var chipsCount: Int
    var player: NCPlayer?

    init(column: Int, chipsCount: Int) {
        self.column = column
        self.chipsCount = chipsCount
    }

    static func moveInColumn(_ column: Int, withCount chipsCount: Int) -> NCMove {
        return NCMove(column: column, chipsCount: chipsCount)
    }
}

extension NCPlayer: GKGameModelPlayer {
    var playerId: Int {
        return type.rawValue
    }
}

extension NCBoard: GKGameModel {
    var players: [any GKGameModelPlayer]? {
        NCPlayer.allPlayers
    }

    var activePlayer: (any GKGameModelPlayer)? {
        currentPlayer
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = NCBoard(chips: cells)
        copy.setGameModel(self)
        return copy
    }

    func setGameModel(_ gameModel: any GKGameModel) {
        guard let gameModel = gameModel as? NCBoard else { return }
        updateChips(from: gameModel)
        currentPlayer = gameModel.currentPlayer
    }

    func gameModelUpdates(for player: any GKGameModelPlayer) -> [any GKGameModelUpdate]? {
        guard let player = player as? NCPlayer else { return nil }

        var moves: [NCMove] = []
        var totalRunCount = 0

        for column in 0..<NCBoard.width {
            totalRunCount += self.chipsInColumn(column, row: 0)
        }

        for column in 0..<NCBoard.width {
            let currentRunCount = totalRunCount
            let chipsInColumn = self.chipsInColumn(column, row: 0)
            if chipsInColumn >= 1 {
                for chipsCount in 1...self.chipsInColumn(column, row: 0) {
                    if self.canRemoveChips(chipsCount, inColumn: column) && (currentRunCount - chipsCount) > 0 {
                        let move = NCMove.moveInColumn(column, withCount: chipsCount)
                        move.player = player
                        moves.append(move)
                    }
                }
            }
        }

        return moves
    }

    func apply(_ gameModelUpdate: any GKGameModelUpdate) {
        guard let gameModelUpdate = gameModelUpdate as? NCMove else { return }

        self.removeChips(gameModelUpdate.chipsCount, inColumn: gameModelUpdate.column)

        var totalRunCount = 0
        for column in 0..<NCBoard.width {
            totalRunCount += self.chipsInColumn(column, row: 0)
        }

        if totalRunCount != NCBoard.countToWin {
            let opponent = currentPlayer.opponent
            self.currentPlayer = opponent
        }
    }

    func isWin(for player: any GKGameModelPlayer) -> Bool {
        guard let player = player as? NCPlayer else { return false }

        var totalRunCount = 0
        for column in 0..<NCBoard.width {
            totalRunCount += self.chipsInColumn(column, row: 0)
        }

        return totalRunCount == NCBoard.countToWin && player == self.currentPlayer
    }

    func isLoss(for player: any GKGameModelPlayer) -> Bool {
        guard let player = player as? NCPlayer else { return false }
        return self.isWin(for: player.opponent)
    }

    func score(for player: any GKGameModelPlayer) -> Int {
        guard let player = player as? NCPlayer else { return 0 }

        var totalRunCount = 0
        for column in 0..<NCBoard.width {
            totalRunCount += self.chipsInColumn(column, row: 0)
        }

        if totalRunCount == NCBoard.countToWin && self.currentPlayer == player {
            return 1
        } else if totalRunCount == NCBoard.countToWin && self.currentPlayer != player {
            return -1
        }

        return 0
    }


}
