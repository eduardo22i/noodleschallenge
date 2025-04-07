//
//  DialogView.swift
//  Noodles Challenge - SK
//
//  Created by Eduardo Irias on 3/31/25.
//  Copyright © 2025 Estamp. All rights reserved.
//

import Foundation

protocol DialogView: AnyObject {
    associatedtype Image

    var image: Image! { get }
    var text: String { get set }
    var isHidden: Bool { get set }
}
