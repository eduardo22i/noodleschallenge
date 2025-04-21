//
//  Dialog.swift
//  Noodles Challenge Mac
//
//  Created by Eduardo Irias on 12/24/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Foundation
import SwiftUI

enum DialogState {
    case wakeUp, instructions, thinking, waiting, celebrating, crying
    
    var texts: [LocalizedString] {
        switch self {
        case .wakeUp:
            return [
                L10n.Dialog.Enemy.wakeUp1,
                L10n.Dialog.Enemy.wakeUp2,
                L10n.Dialog.Enemy.wakeUp3
            ]
        case .instructions:
            return [
                L10n.Dialog.Enemy.instructions1,
                L10n.Dialog.Enemy.instructions2(GameSceneComponent.config.count),
                L10n.Dialog.Enemy.instructions3,
                L10n.Dialog.Enemy.instructions4,
                L10n.Dialog.Enemy.instructions5,
                L10n.Dialog.Enemy.instructions6
            ]
        case .waiting:
            return [
                L10n.Dialog.Enemy.waiting1,
                L10n.Dialog.Enemy.waiting2,
                L10n.Dialog.Enemy.waiting3,
                L10n.Dialog.Enemy.waiting4,
                L10n.Dialog.Enemy.waiting5
            ]
        case .thinking:
            return [
                L10n.Dialog.Enemy.thinking1,
                L10n.Dialog.Enemy.thinking2,
                L10n.Dialog.Enemy.thinking3,
                L10n.Dialog.Enemy.thinking4
            ]
        case .celebrating:
            return [
                L10n.Dialog.Enemy.celebrating
            ]
        case .crying:
            return [
                L10n.Dialog.Enemy.crying
            ]
        }
    }
}

class Dialog: Entity {

    override init() {
        super.init()
        addComponent(EnemyDialogComponent())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Dialog {
    var dialogComponent: EnemyDialogComponent {
        guard let enemyDialogComponent = component(ofType: EnemyDialogComponent.self) else {
            fatalError()
        }
        return enemyDialogComponent
    }

}

class EnemyDialogComponent: Component {
    private var renderComponent: RenderableComponent<any DialogView> {
        guard let render = entity?.component(ofType: RenderableComponent<any DialogView>.self) else {
            fatalError()
        }
        return render
    }

    var state: DialogState = .wakeUp
    private(set) var currentDialogIndex = 0

    func resetDialog() {
        currentDialogIndex = 0
    }

    func nextDialogInQueue() {
        currentDialogIndex += 1
    }

    func setRandomDialogFromState() {
        currentDialogIndex = Int.random(in: 0..<state.texts.count)
    }

    func render() {
        renderComponent.renderable.text = state.texts[currentDialogIndex].text
    }

    func showDialog() {
        renderComponent.renderable.isHidden = false
    }

    func hideDialog() {
        renderComponent.renderable.isHidden = true
    }
}
