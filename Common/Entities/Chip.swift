//
//  Chip.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/23/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import SpriteKit

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

final class ChipSK: SKSpriteNode, ChipView {
    weak var logic: Chip?

    init() {
        let texture = SKTexture(imageNamed: "Coin")

        super.init(texture: texture, color: NSColor.clear, size: texture.size())
        
        self.name = "coin"
        
        let shadow = SKSpriteNode(imageNamed: "CoinShadow")
        shadow.scale(to: CGSize(width: 38, height: 12))
        shadow.alpha = 0.8
        shadow.colorBlendFactor = 0.2
        self.addChild(shadow)
        shadow.position.y = -36
        shadow.zPosition = 1
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(status: Bool) {
        self.alpha = status ? 0.4 : 1.0
    }
}
