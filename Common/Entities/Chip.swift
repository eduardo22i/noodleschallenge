//
//  Chip.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation

protocol ChipEntity: Entity {
    var renderableComponent: RenderableComponent<any ChipView> { get }
    var chipComponent: ChipComponent { get }
}

final class Chip: Entity, ChipEntity {

    var renderableComponent: RenderableComponent<any ChipView> {
        guard let render = component(ofType: RenderableComponent<any ChipView>.self) else {
            fatalError()
        }
        return render
    }

    var chipComponent: ChipComponent {
        guard let component = component(ofType: ChipComponent.self) else {
            fatalError()
        }
        return component
    }

}
