//
//  ChipController.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation

protocol ChipControllable: AnyObject {
    var view: any ChipView { get }
    var index: UUID { get }
    var boxIndex: Int { get }
    var box: String { get }

    var isSelected: Bool { get set }
}

final class ChipController: ChipControllable {
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

extension ChipController: ChipViewDelegate {
    
}
