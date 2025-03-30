//
//  NCPlayer.swift
//  Noodles Challenge
//
//  Created by Eduardo Irias on 3/4/25.
//  Copyright © 2025 Estamp. All rights reserved.
//
import Foundation

enum NCType: Int {
    case none = 0
    case human
    case computer
}

class NCPlayer: NSObject {
    var type: NCType
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

    private init(type: NCType) {
        self.type = type
        super.init()
    }

    static var humanPlayer: NCPlayer {
        player(for: .human)!
    }

    static var computerPlayer: NCPlayer {
         player(for: .computer)!
    }

    private static func player(for type: NCType) -> NCPlayer? {
        switch type {
        case .none:
            nil
        case .human:
            allPlayers[0]
        case .computer:
            allPlayers[1]
        }
    }

    static let allPlayers: [NCPlayer] = [
            NCPlayer(type: .human),
            NCPlayer(type: .computer)
    ]
    

    var opponent: NCPlayer {
        switch type {
        case .human:
            return NCPlayer.computerPlayer
        case .computer:
            return NCPlayer.humanPlayer
        default:
            fatalError("Not a valid player")
        }
    }
}
