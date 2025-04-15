//
//  PlayerComponent.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 4/15/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

final class PlayerComponent: Component {
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static var humanPlayer: PlayerComponent {
        player(for: .human)!
    }

    static var computerPlayer: PlayerComponent {
         player(for: .computer)!
    }

    private static func player(for type: PlayerType) -> PlayerComponent? {
        switch type {
        case .none:
            nil
        case .human:
            allPlayers[0]
        case .computer:
            allPlayers[1]
        }
    }

    static let allPlayers: [PlayerComponent] = [
        PlayerComponent(type: .human),
        PlayerComponent(type: .computer)
    ]

    var opponent: PlayerComponent {
        switch type {
        case .human:
            return PlayerComponent.computerPlayer
        case .computer:
            return PlayerComponent.humanPlayer
        default:
            fatalError("Not a valid player")
        }
    }
}
