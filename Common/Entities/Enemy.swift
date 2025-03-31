//
//  Enemy.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation

enum EnemyState {
    case sleeping, explaining, waiting, thinking, celebrating, crying
}

protocol Enemy {
    var view: EnemyView { get }

    var state: EnemyState { get set }

    func wakeUp()
    func wait()
}

final class EnemyLogic: Enemy {
    var view: EnemyView

    var state = EnemyState.sleeping {
        didSet {
            if oldValue == .sleeping && state == .explaining {
                view.wakeUp()
            }

            if state == .thinking {
                view.think()
            }

            if state == .waiting {
                view.wait()
            }

            if state == .celebrating {
                view.celebrate()
            }

            if state == .crying {
                view.cry()
            }
        }
    }

    init(view: EnemyView, state: EnemyState = EnemyState.sleeping) {
        self.view = view
        self.state = state
    }

    func wakeUp() {
         state = .explaining
    }

    func wait() {
        state = .waiting
    }
}

