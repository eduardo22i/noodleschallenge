//
//  BoardView.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 3/31/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

protocol BoardView: AnyObject {
    func addBox(index: Int) -> any BoxView
}
