//
//  BoxView.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 3/31/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

protocol BoxView: AnyObject {
    func remove(chips: [any ChipView])
    func addChip(index: Int, total: Int) -> ChipView

    /// Remove from parent to clean up the scene
    func removeFromParent()
}
