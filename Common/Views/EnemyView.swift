//
//  EnemyView.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 3/31/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

protocol EnemyView {
    func stopAnimations()

    func wakeUp()
    func think()
    func wait()
    func celebrate()
    func cry()
}
