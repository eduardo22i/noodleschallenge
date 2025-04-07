//
//  GameSceneView.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 3/31/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

protocol GameSceneView: AnyObject {
    var logic: GameScene? { get set }

    func addEnemyView(_ enemyView: EnemyView)
    func addBoardView(_ boardView: BoardView)

    func disableContinueButton()
    func hideContinueButton()
    func hideButtons()
    func showButtons()
}
