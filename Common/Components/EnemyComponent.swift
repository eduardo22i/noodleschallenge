//
//  EnemyComponent.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 4/2/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

enum EnemyState {
    case sleeping, explaining, waiting, thinking, celebrating, crying
}

final class EnemyComponent: Component {

    private var view: any EnemyView {
        guard let render = entity?.component(ofType: RenderableComponent<any EnemyView>.self) else {
            fatalError()
        }
        return render.renderable
    }

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

    init(state: EnemyState = EnemyState.sleeping) {
        self.state = state
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func wakeUp() {
         state = .explaining
    }

    func wait() {
        state = .waiting
    }
}
