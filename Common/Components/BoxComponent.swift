//
//  BoxComponent.swift
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

final class BoxComponent: Component {

    var index: Int

    var type: BoxType
    var chips: [any ChipControllable] = [ChipControllable]()

    init(index: Int, type: BoxType = .elseB) {
        self.type = type
        self.index = index
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func remove(chips: [any  ChipControllable]) {
        self.chips.removeAll { chip -> Bool in
            return chips.contains { removeChip in
                chip.index == removeChip.index
            }
        }
        (entity as? BoxEntity)?.renderableComponent.renderable.remove(chips: chips.map { $0.view })
    }

    func addCoins(count: Int) {
        for coinIndex in 0..<count {
            let chipView = (entity as? BoxEntity)?.renderableComponent.renderable.addChip(index: coinIndex, total: count)
            let chip = ChipController(view: chipView!, boxIndex: index, index: coinIndex)
            chipView!.chip = chip
            chips.append(chip)
        }
    }
}
