//
//  GameViewController.swift
//  HWS Project 29 Exploding Monkeys
//
//  Created by Mohammed Qureshi on 2021/02/24.
//

import UIKit
import SpriteKit
import GameplayKit


//We'll add controls to the SKView so the player can fire a banana at the angle they want.
//using a UISlider to select the angle and buttons to fire.
//GVC needs to manage the UI but needs to talk to the GameScene. The GameScene need to also talk to this GVC to tell when the player can fire a banana. So we need to create properties that hold each other's references.

//In the IB we added labels and sliders for the angle and velocity changed. In the size inspector its quite simple to set the X and Y positions and width for each of the labels and sliders. You can also change starting and maximum values for the sliders in IB.


class GameViewController: UIViewController {
    
    var currentGame: GameScene? // to be able to speak to the gamescene.

    
    @IBOutlet var angleSlider: UISlider!
    
    @IBOutlet var angleLabel: UILabel!
    
    @IBOutlet var velocitySlider: UISlider!
    
    @IBOutlet var velocityLabel: UILabel!
    
    @IBOutlet var launchButton: UIButton!
    
    @IBOutlet var playerLabel: UILabel!
    
    @IBOutlet weak var player1Score: UILabel!
    //@IBOutlet weak var player1Score: UILabel!
    //non key coding compliant error again. Deleting IBOutlets in outlet inspector solves this.
    
    @IBOutlet weak var player2Score: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                //for the review section, this method needs to be called on the SKView that owns our game scene aka this view.
                
                currentGame = scene as? GameScene
                currentGame?.viewController = self //set vc property as self to establish connection to game scene
                
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        angleChanged(self)
        velocityChanged(self) // declare their default values up here in viewDidLoad.
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

    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°" //UI Sliders are always of value float. Shift + option + 8 gives us the degrees symbol.
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))" //we convert the velocity slider's value into an Int by typecasting it here.
    }
    
    @IBAction func launch(_ sender: Any) {
        //we need to hide the UI when the banana is launched so the player can't keep launching bananas repeatedly
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocityLabel.isHidden = true
        velocitySlider.isHidden = true
        
        launchButton.isHidden = true
        
        //launch func needs to be in the GameScene.
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value)) //currentGame needed to be unwrapped as GameScene is an optional.
        
    }
    
    func activatePlayer(number: Int) {
        //needed to use the internal param name here no
        if number == 1 {
            playerLabel.text = "<<<PLAYER ONE"
        } else if number == 2 {
            playerLabel.text = "PLAYER TWO>>>"
        }
        
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocityLabel.isHidden = false
        velocitySlider.isHidden = false
        
        launchButton.isHidden = false
    }
    
}
