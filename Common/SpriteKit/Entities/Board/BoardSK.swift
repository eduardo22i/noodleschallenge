//
//  BoardSK.swift
//  Noodles Challenge iOS
//
//  Created by Eduardo Irias on 7/11/23.
//  Copyright © 2023 Estamp. All rights reserved.
//

import SpriteKit

final class BoardSK: SKSpriteNode, BoardView {

    init() {
        let texture = SKTexture(imageNamed: "Board")
        super.init(texture: texture, color: NSColor.clear, size: texture.size())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Functions

    func addBox(index: Int, x: CGFloat, y: CGFloat) -> any BoxView {

        let type: BoxType = {
            switch index {
            case 0:
                return BoxType.leftBottom
            case 1:
                return BoxType.rightBottom
            case 2:
                return BoxType.centerTop
            default:
                return BoxType.elseB
            }

        }()

        let box = BoxSK(index: index, type: type)
        box.position.x = x
        box.position.y = y
        box.zPosition = 2
        self.addChild(box)

        return box
    }

}
