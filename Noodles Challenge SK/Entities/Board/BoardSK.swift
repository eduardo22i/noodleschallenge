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
        super.init(texture: texture, color: .clear, size: texture.size())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Functions

    func addBox(index: Int) -> any BoxView {

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

        let x: CGFloat = index == 0 ? -160 : (index == 1 ? 200 : 0)
        let y: CGFloat = index == 0 ? -40 : (index == 2 ? 200 : -40)

        let box = BoxSK(index: index, type: type)
        box.position.x = x
        box.position.y = y
        box.zPosition = 2
        self.addChild(box)

        return box
    }

}
