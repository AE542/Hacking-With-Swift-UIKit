//
//  GameViewController.swift
//  Project 20 HWS Fireworks Night
//
//  Created by Mohammed Qureshi on 2020/12/10.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
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
    // func for detecting shaking.
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard let skView = view as? SKView else { return } //bail out if anything else is shown
        guard let gameScene = skView.scene as? GameScene else { return } //any other scene is shown, don't call the next method
        gameScene.explodeFireworks() //when device is shaken
      
        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        guard let skView = view as? SKView else { return } //bail out if anything else is shown
//        guard let gameScene = skView.scene as? GameScene else { return } //any other scene is shown, don't call the next method
//        gameScene.
//    }//not working for challenge 3
}
