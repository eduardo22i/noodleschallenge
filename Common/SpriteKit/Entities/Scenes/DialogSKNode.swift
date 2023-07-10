//
//  DialogSKNode.swift
//  Noodles Challenge iOS
//
//  Created by Eduardo Irias on 7/11/23.
//  Copyright © 2023 Estamp. All rights reserved.
//

import SpriteKit

class DialogSKNode: SKSpriteNode, DialogView {

    internal var image: SKSpriteNode!
    internal var text: String = "" {
        didSet {
            let labelNode = self.childNode(withName: "text") as? SKLabelNode
            labelNode?.text = text
        }
    }

    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

