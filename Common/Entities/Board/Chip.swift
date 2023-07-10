//
//  Chip.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation

protocol Chip: AnyObject {
    var view: any ChipView { get }
    var index: UUID { get }
    var boxIndex: Int { get }
    var box: String { get }

    var isSelected: Bool { get set }
}

final class ChipLogic: Chip {
    var view: any ChipView

    var index = UUID()
    let boxIndex: Int
    let box: String

    var isSelected = false {
        didSet {
            view.setSelected(status: isSelected)
        }
    }

    init(view: any ChipView, boxIndex: Int, index: Int) {
        self.view = view
        self.boxIndex = boxIndex
        self.box = "box\(boxIndex)"
    }
}

protocol ChipView: AnyObject {
    var logic: Chip? { get set }

    func setSelected(status: Bool)
    /// Remove from parent to clean up the scene
    func removeFromParent()
}
