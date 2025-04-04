//
//  Board.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation

final class Board: Entity {

    var renderableComponent: any BoardView {
        guard let render = component(ofType: RenderableComponent<any BoardView>.self) else {
            fatalError()
        }
        return render.renderable
    }

    var gameModel: BoardComponent {
        guard let gameModel = component(ofType: BoardComponent.self) else {
            fatalError()
        }
        return gameModel
    }

}
