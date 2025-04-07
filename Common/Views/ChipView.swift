//
//  ChipView.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 3/31/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

protocol ChipView: AnyObject {
    var component: RenderableComponent<ChipView>? { get set }

    func setSelected(status: Bool)
    /// Remove from parent to clean up the scene
    func removeFromParent()
}
