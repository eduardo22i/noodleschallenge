//
//  ImageAsset+SpriteKit.swift
//  Noodles Challenge iOS
//
//  Created by Eduardo Irias on 7/15/23.
//  Copyright © 2023 Estamp. All rights reserved.
//

import SpriteKit

extension ImageAsset {
    var skTexture: SKTexture {
        SKTexture(imageNamed: self.name)
    }
}
