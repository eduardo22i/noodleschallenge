//
//  DialogController.swift
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
                L10n.Dialog.Enemy.instructions2(GameSceneController.config.count),
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

protocol DialogControllable {
    var view: any DialogView { get set }

    var state: DialogState { get set }
    var currentDialogIndex: Int { get }
    func resetDialog()
    func nextDialogInQueue()
    func setRandomDialogFromState()

    func render()
    func showDialog()
    func hideDialog()
}

final class DialogController: DialogControllable {
    internal init(view: any DialogView, state: DialogState = .wakeUp, currentDialogIndex: Int = 0) {
        self.view = view
        self.state = state
        self.currentDialogIndex = currentDialogIndex
    }


    var view: any DialogView

    var state: DialogState = .wakeUp
    var currentDialogIndex = 0

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
        view.text = state.texts[currentDialogIndex].text
    }

    func showDialog() {
        view.isHidden = false
    }

    func hideDialog() {
        view.isHidden = true
    }
}
