//
//  BoxController.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation

enum BoxType: String {
    case centerTop = "BoxCenterTop"
    case leftBottom = "BoxLeftBottom"
    case rightBottom = "BoxRightBottom"
    case elseB = "Paper"

    var offsetX: Double {
        switch self {
        case .leftBottom:
            return 10.0
        case .rightBottom:
            return -10.0
        default:
            return 0.0
        }
    }
}

protocol BoxControllable {
    var view: any BoxView { get }

    var index: Int { get }
    var type: BoxType { get }
    var chips: [any ChipControllable] { get }

    func addCoins(count: Int)
    func remove(chips: [any ChipControllable])
}

final class BoxController: BoxControllable {

    var view: any BoxView

    var index: Int

    var type: BoxType
    var chips: [any ChipControllable] = [ChipControllable]()

    init(view: any BoxView, index: Int, type: BoxType = .elseB) {
        self.view = view
        self.type = type
        self.index = index
    }

    func remove(chips: [any  ChipControllable]) {
        self.chips.removeAll { chip -> Bool in
            return chips.contains { removeChip in
                chip.index == removeChip.index
            }
        }

        view.remove(chips: chips.map { $0.view })
    }

    func addCoins(count: Int) {
        for coinIndex in 0..<count {
            let chipView = view.addChip(index: coinIndex, total: count)
            let chip = ChipController(view: chipView, boxIndex: index, index: coinIndex)
            chipView.chip = chip
            chips.append(chip)
        }
    }
}
