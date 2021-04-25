//
//  GameScene.swift
//  Project 14 HWS Whack-a-Mole
//
//  Created by Mohammed Qureshi on 2020/10/19.
//  Copyright © 2020 Experiment1. All rights reserved.
//
//before starting on building games using SpriteKit, remember the clean up first
// delete actions.sks
// delete hello world from game scene change the width and height to 1024 x 768
// delete all the code in this class as you won't use it, only for demo purposes. Leave override func add touches began method.
//add image files from folder then remember that sound files should be seperate and added below info.plist but not in the assets folder.
import SpriteKit


class GameScene: SKScene {
    
    var slots = [WhackSlot]()

    var gameScore: SKLabelNode!
    
    var finalScore: SKLabelNode!// for challenge
    
    var popUptime = 0.85 // need to create create enemy method once when game starts and then call itself after game starts, but not immediately
    
    var numRounds = 0 // to allow a limit to number of rounds for the game.

    var score = 0 {
        //property observer
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384) // in the exact centre of the view
        background.blendMode = .replace //draws the sprite into the parent's frame buffer
        background.zPosition = -1 // height of node relative to its parent.
        addChild(background)// adds node to end of list of child nodes
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)// bottom to top in SpriteKit so this is right at the bottom of the view
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        //this is for positions of the rows of slots on screen. We take the createSlot method below and use it here in the loops making the y position a little less each time.
        for i in 0..<5 { createSlot(at: CGPoint (x: 100 + (i * 170), y: 440)) }
        for i in 0..<4 { createSlot(at: CGPoint (x: 180 + (i * 170), y: 360)) }
        for i in 0..<5 { createSlot(at: CGPoint (x: 100 + (i * 170), y: 250)) }
        for i in 0..<4 { createSlot(at: CGPoint (x: 180 + (i * 170), y: 170)) }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()// delay changed to 1 second from below now the enemy
        }
        
        //11 inch iPad pro is slightly different in that aspect ratio is larger. Score Label is cut off in simulator. We need to get SpriteKit to slightly stretch
        
}// put override func outside of this func as its overriding the class not the didMove func.

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // if can't read the first touch, bail out immediately.
        let location = touch.location(in: self)//where the user touches the screen.
        let tappedNodes = nodes(at: location)
        //we can loop over to find if friend or enemy penguin is tapped
        
        
        
        
        for node in tappedNodes {
            // friend charNode is a sprite node inside a cropNode which is inside the WhackSlot class. WS Class Has isVisible and isHit methods. Has to read the parent of node that was tapped and the parent of that parent needs to be typecasted as WhackSlot. See below.
               
            
            guard let whackSlot = node.parent?.parent as? WhackSlot else {
                continue // goes to next tappedNode if fails.
            }
            
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                //shouldn't have hit this penguin.
                
                //one useful thing was the if whackSlot isVisible and isHit if statements were duplicated here and in the else if below. To reduce duplication and for ease of readabilty, moved to above the if this if statement and were deleted from these if and else if statements.
                            
                score -= 5
                
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))// plays .caf file sound
                
            } else if node.name == "charEnemy" {
                //should have hit this one.
               
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                whackSlot.hit()
                score += 1
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
}
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }// hard part is putting slots in correct position

    func createEnemy() {
        
        numRounds += 1
        
        if numRounds >= 30 {
            for slot in slots {
                //slot.emerge()
                slot.hide()
                //emerge()
            }
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            run(SKAction.playSoundFileNamed("gameOver.caf", waitForCompletion: true))
            //attempt at challenge 1
            //only accepts caf (Core Audio Files) came across as white noise when game over hits.
            let finalScore1 = SKLabelNode(text: gameScore.text)
            finalScore1.fontName = "Chalkduster"
            finalScore1.fontColor = .white
            finalScore1.fontSize = 40

         //"\(String(describing: gameScore.text))")// caused error and couldn't load the game score because there is no gamescore file to draw from.
            finalScore1.position = CGPoint(x: 512, y: 300)
            finalScore1.zPosition = 2
            addChild(finalScore1)
            
            return // this allows us to stop calling createEnemy and the game is finished.
        }
        
        popUptime *= 0.991// this allows the pop up time to decrease slowly to increase the difficulty of the game.
        
        slots.shuffle()// shuffles Whack Slots array
        slots[0].show(hideTime: popUptime)
        //slots[0].emerge()
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popUptime) } //TC syntax
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popUptime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popUptime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popUptime) }
        // this shuffles the slots, chooses an int between 0 and 12 greater than 4 to show the slots which is determined by the popUpTime. Will show more than 4 slots at once.
        //now we need to call the enemy after a period of time to continue the game
        //needs randomness to avoid predictability
        
        //if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popUptime); emerge() } adding emerge didn't work
        let minDelay = popUptime / 2.0
        let maxDelay = popUptime * 2.0
        
        let delay = (Double.random(in: minDelay...maxDelay))// closed range double
        //then we need to call it using GCD main async after.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()// create enemy calls itself now
            //self?.emerge()
        }
        
    }
    
    func emerge() {
        if let mudParticles = SKEmitterNode(fileNamed: "emerge.sks") {
            mudParticles.particleScale = 0.2
           // magicParticles.particleScaleRange = 0.2
            mudParticles.particleColor = .brown
            mudParticles.particleSpeed = 0.5
            mudParticles.particleLifetime = 0.05
            
            //magicParticles.position = .position
            addChild(mudParticles)
        }
    }
    func smokeHit(){
        //if let particles =
        if let smokeParticles = SKEmitterNode(fileNamed: "smoke.sks") {
        smokeParticles.particleScale = 0.2;
        //smokeParticles.particleScaleRange = 0.2;
        //smokeParticles.particleScaleSpeed = -0.1
        smokeParticles.particleLifetime = 0.05
            smokeParticles.particleSpeed = 0.2
        //smokeParticles.position = charNode.position //this might allow it to work
        //return SKEmitterNode(fileNamed: "MyParticle.sks")
        addChild(smokeParticles)
        }
    //func touchesBegan shouldn't be here can't use override func
}
}
