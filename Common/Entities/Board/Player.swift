//
//  Player.swift
//  Noodles Challenge
//
//  Created by Eduardo Irias on 3/4/25.
//  Copyright © 2025 Estamp. All rights reserved.
//
import Foundation

enum PlayerType: Int {
    case none = 0
    case human
    case computer
}

class Player: NSObject {
    var type: PlayerType
    var name: String {
        switch type {
        case .human:
            return "Red"
        case .computer:
            return "COMPUTER"
        default:
            return ""
        }
    }

    override var debugDescription: String {
        switch type {
        case .human:
            return "X"
        case .computer:
            return "O"
        default:
            return " "
        }
    }

    private init(type: PlayerType) {
        self.type = type
        super.init()
    }

    static var humanPlayer: Player {
        player(for: .human)!
    }

    static var computerPlayer: Player {
         player(for: .computer)!
    }

    private static func player(for type: PlayerType) -> Player? {
        switch type {
        case .none:
            nil
        case .human:
            allPlayers[0]
        case .computer:
            allPlayers[1]
        }
    }

    static let allPlayers: [Player] = [
            Player(type: .human),
            Player(type: .computer)
    ]

    var opponent: Player {
        switch type {
        case .human:
            return Player.computerPlayer
        case .computer:
            return Player.humanPlayer
        default:
            fatalError("Not a valid player")
        }
    }
}
