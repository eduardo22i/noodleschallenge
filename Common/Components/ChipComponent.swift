//
//  ChipComponent.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 4/8/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

final class ChipComponent: Component {

    var index = UUID()
    let boxIndex: Int
    let box: String

    var isSelected = false

    init(boxIndex: Int, index: Int) {
        self.boxIndex = boxIndex
        self.box = "box\(boxIndex)"
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
