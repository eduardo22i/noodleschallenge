//
//  GameViewController.swift
//  Tea Challenge
//
//  Created by Eduardo Irias on 12/19/18.
//  Copyright © 2018 Estamp. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

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

                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFit
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }

                logic.start()
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
