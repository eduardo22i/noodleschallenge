//
//  Box.swift
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

protocol Box {
    var view: any BoxView { get }

    var index: Int { get }
    var type: BoxType { get }
    var chips: [any Chip] { get }

    func addCoins(count: Int)
    func remove(chips: [any Chip])
}

final class BoxLogic: Box {

    var view: any BoxView

    var index: Int

    var type: BoxType
    var chips: [any Chip] = [Chip]()

    init(view: any BoxView, index: Int, type: BoxType = .elseB) {
        self.view = view
        self.type = type
        self.index = index
    }

    func remove(chips: [any  Chip]) {
        self.chips.removeAll { chip -> Bool in
            return chips.contains { removeChip in
                chip.index == removeChip.index
            }
        }

        view.remove(chips: chips.map { $0.view })
    }

    func addCoins(count: Int) {
        for coinIndex in 0..<count {
            let separation = 52.0
            let offset = Double(coinIndex) / Double(count)
            let angle =  offset * Double.pi * 2.0
            let x = sin(angle) * separation + self.type.offsetX
            let y = cos(angle) * separation + 30.0

            let chipView = view.addChip(x: CGFloat(x), y: CGFloat(y), index: coinIndex)
            let chip = ChipLogic(view: chipView, boxIndex: index, index: coinIndex)
            chipView.logic = chip
            chips.append(chip)
        }
    }
}

protocol BoxView: AnyObject {
    func remove(chips: [any ChipView])
    func addChip(x: CGFloat, y: CGFloat, index: Int) -> ChipView

    /// Remove from parent to clean up the scene
    func removeFromParent()
}
