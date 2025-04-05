//
//  Box.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 4/6/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

protocol BoxEntity: Entity {
    var renderableComponent: RenderableComponent<any BoxView> { get }
    var boxComponent: BoxComponent { get }
}

final class Box: Entity, BoxEntity {
    var renderableComponent: RenderableComponent<any BoxView> {
        guard let render = component(ofType: RenderableComponent<any BoxView>.self) else {
            fatalError()
        }
        return render
    }

    var boxComponent: BoxComponent {
        guard let component = component(ofType: BoxComponent.self) else {
            fatalError()
        }
        return component
    }
}
