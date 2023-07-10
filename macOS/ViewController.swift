//
//  ViewController.swift
//  Tea Challenge Mac
//
//  Created by Eduardo Irias on 12/19/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.

        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameSceneSK? {
                let logic = GameSceneLogic(
                    view: sceneNode,
                    board: BoardLogic(view: BoardSK(), config: GameSceneLogic.config),
                    enemy: EnemyLogic(view: EnemySK(name: "Obinoby"))
                )
                sceneNode.logic = logic
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFit
                
                // Present the scene
                if let view = self.skView {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }

                logic.start()
            }
        }
    }
}

