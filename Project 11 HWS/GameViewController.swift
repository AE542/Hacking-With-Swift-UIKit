//
//  GameViewController.swift
//  Project 11 HWS
//
//  Created by Mohammed Qureshi on 2020/09/13.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {// changing SKScene to Gamescene helped load the game properly. Can't call UIKit Subviews from SKScene.
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
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
    
//    func resetScore() {
//    let ac = UIAlertController(title: "Game Over", message: "Your score is \(String(describing: scoreLabel))", preferredStyle: .alert)
//               ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: Reset))
//                   present(ac, animated: true)
//}
//    @objc func Reset(action: UIAlertAction) {
//        if usedBalls < noOfBalls {
//            score = 0
//            usedBalls = 5
//            
//        }
//    }
}

