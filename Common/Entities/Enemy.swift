//
//  Enemy.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation

final class EnemyEntity: Entity {

    var renderableComponent: any EnemyView {
        guard let render = component(ofType: RenderableComponent<any EnemyView>.self) else {
            fatalError()
        }
        return render.renderable
    }

    var enemyComponent: EnemyComponent {
        guard let enemyComponent = component(ofType: EnemyComponent.self) else {
            fatalError()
        }
        return enemyComponent
    }

    override init() {
        super.init()
        addComponent(EnemyComponent())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
