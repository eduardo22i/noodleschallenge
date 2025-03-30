//
//  GameModelStrategist.swift
//  Noodles Challenge
//
//  Created by Eduardo Irias on 3/30/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import GameplayKit

protocol GameModelStrategist: AnyObject {
    var maxLookAheadDepth: Int { get set }
    var gameModel: (any GKGameModel)? { get set }
    func bestMoveForActivePlayer() -> (any GKGameModelUpdate)?
}

extension GKMinmaxStrategist: GameModelStrategist { }
