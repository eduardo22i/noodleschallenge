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

protocol PlayerEntity {
    var playerComponent: PlayerComponent { get }
}

final class Player: Entity, PlayerEntity {

    var playerComponent: PlayerComponent {
        guard let component = component(ofType: PlayerComponent.self) else {
            fatalError()
        }
        return component
    }
}
