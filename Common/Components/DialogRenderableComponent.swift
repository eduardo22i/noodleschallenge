//
//  DialogRenderableComponent.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 4/2/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

class DialogRenderableComponent: Component {
    var renderable: any DialogView

    init(renderable: any DialogView) {
        self.renderable = renderable
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
