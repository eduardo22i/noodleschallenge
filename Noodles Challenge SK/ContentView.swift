//
//  ContentView.swift
//  Noodles Challenge iOS
//
//  Created by Eduardo Irias on 7/15/23.
//  Copyright © 2023 Estamp. All rights reserved.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = SKScene(fileNamed: "GameScene")!
        if let scene = scene as? GameSceneSK {

            let logic = GameSceneLogic(
                view: scene,
                board: Board(view: BoardSK(), config: GameSceneLogic.config),
                enemy: EnemyLogic(view: EnemySK(name: "Obinoby"))
            )

            #if os(tvOS)
            scene.isScrollingInput = true
            #endif

            logic.start()

        }

        scene.scaleMode = .aspectFit
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
