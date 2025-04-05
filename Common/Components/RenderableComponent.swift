//
//  RenderableComponent.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 4/2/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

protocol Renderable {

}

class RenderableComponent<V>: Component {
    var renderable: V

    init(renderable: V) {
        self.renderable = renderable
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
