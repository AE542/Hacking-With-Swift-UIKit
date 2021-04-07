//
//  GameScene.swift
//  Project 11 HWS
//
//  Created by Mohammed Qureshi on 2020/09/13.
//  Copyright © 2020 Experiment1. All rights reserved.
//
import UIKit
import SpriteKit
//before setting up here we needed to go to GameScene.sks to change the size to 1024 x 768 (standard iPad size) and Anchor Point at (0,0)
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode! //implictly unwrapped.
    var ballLabel: SKLabelNode! //again implicitly unwrapped remember it may contain a value, it might not. But they don't need to be checked before they are used. Remember Checking means unwrapping. Swift eliminates the need for unwrapping because we're telling swift to unwrap a value regardless if it is nil or not. if nil it will crash.
     let noOfBalls = 0
    var usedBalls = 5 {
        didSet {
            ballLabel.text = "Balls: \(usedBalls)"
        }// this is working in showing the balls left on the screen but how to stop the game when its 0 balls...
    }
    var score = 0 {
        didSet {//property observer.
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
//    var resetLabel: SKLabelNode!
//    var resetButton: Bool = false {
//        didSet {
//            resetLabel.text = "Reset"
//        }
//    }
    
    let allBalls = ["ballRed","ballYellow", "ballBlue", "ballGreen","ballBlue","ballCyan", "ballPurple", "ballGrey"] //tried creating an array for challenge 1 here.
    //you didn't need to add SKSpriteNode and imageNamed to each ball name here.
    
    override func didMove(to view: SKView) {
        
    let background = SKSpriteNode(imageNamed: "background")//loads the background for the app SKSpriteNode is the actual image or colour that's loaded in from the assets here.
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace //determines how a node is drawn. Also works faster in simulator
        background.zPosition = -1 //draw this behind everything else
        addChild(background)
        
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkDuster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right //left/right/center alignment setting.
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)// creates score Label and the property observer changes when the score is updated and it is position on the screen
        
        ballLabel = SKLabelNode(fontNamed: "ChalkDuster")
        ballLabel.text = "Balls: 5"
        ballLabel.horizontalAlignmentMode = .center
        ballLabel.position = CGPoint(x: 650, y: 700)
        addChild(ballLabel)
    
        
        editLabel = SKLabelNode(fontNamed: "ChalkDuster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        //this adds the label to the CGPoints desginated above. Similar to creating score label.
        
//        resetLabel = SKLabelNode(fontNamed: "ChalkDuster")
//        resetLabel.text = "Reset"
//        resetLabel.position = CGPoint(x: 200, y: 700)
//        addChild(resetLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)// this allows the boxes to have physics and fall when they appear.
        
        physicsWorld.contactDelegate = self // comes from SKScene
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        //this is to place the slots in the correct places. Between the bouncers. If we want to change how the slots look we can just change it in one place instead of in each func if we made them 4 times.
        
        makeBouncer(at: CGPoint(x:0, y:0))
        makeBouncer(at: CGPoint(x:256, y:0))
        makeBouncer(at: CGPoint(x:512, y:0))
        makeBouncer(at: CGPoint(x:768, y:0))
        makeBouncer(at: CGPoint(x:1024, y:0))
        //could have wrote make bouncer method 5 times but that's inefficient making a method below and then just creating these line of codes is better for readability.
        

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {// called when users touch the screen.
        guard let touch = touches.first else { return }
        let location = touch.location(in: self )// find where touch was in game scene
        //let location = touch.location(in: CGPoint(x: 700, y: 800)) this didn't work for getting the balls to appear at the top. Error No exact matches in call to instance method 'location(in:)
        //let ballLocation = CGRect(x: 500, y: 600, width: 700, height: 200)
        //let ballLocation = CGRect(x: 500, y: 600, width: 900, height: 300) immutable value was never used error... can't convert CGRect to CG Point

        //need to check if the user tapped the edit button or not.
    
        
        
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()// flips boolean value same as editingMode = !editingMode
        } else {
            if editingMode {
                //create box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)// make random size
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)// SKSprite node with random colours.
                box.zRotation = CGFloat.random(in: 0...5)//rotate a random number of radients
                box.position = location
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)//give rectangle physics body
                box.physicsBody?.isDynamic = false
                addChild(box)
                //add y position of balls at the top of the screen later.
                
                
            } else if usedBalls != noOfBalls {// HOLY CRAP I FINALLY DID IT!! THIS WAS THE SOLUTION TO CHALLENGE 3!!!!
    //try mutating func here later
        //let ball = SKSpriteNode(imageNamed: "ballRed")
            
                
                let ball = SKSpriteNode(imageNamed: allBalls.randomElement() ?? "ballRed")
                //THIS WAS THE SOLUTION.need to have allBalls.randomElement() ?? "ballRed" like Paul did in the project video.
                //One of the solutions was to use the nil coalescing operator and "ballRed" as default value remember:
                //Swift's nil coalescing operator helps you solve this problem by either unwrapping an optional if it has a value, or providing a default if the optional is empty. So it defaults to ball red if nothing is in the allBalls array.
//                    if noOfBalls < 5 {
                
               // ball.childNode(withName: "\(noOfBalls)")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)//is half the width of the ball.
        ball.physicsBody?.restitution = 0.4//determines bounciness optional chaining with ? but we created the ball in the previous line.
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        //collisionBitMask tells which object the ball should hit. contactTestBitMask means which collisions do you want to know about? = you're bouncing off everything while also telling us about them aswell. Needs nil coalescing operator here because there may not be a physicsBody but we created it above.
                ball.position = CGPoint(x: 512, y: 700)
                //For now this is the best solution at least it fixes the yValue in the middle of the screen so you have to play it like an actual pachinko game.
                //can't change the x value to a closed range Int. which sucks... this error comes up Cannot convert value of type 'ClosedRange<Int>' to expected argument type 'Int'
                //For Challenge 2 attempted to create a rectangle to handle the images but it didn't work can't assign int values to CGSize ones.
                //ball.position = CGPoint(x: 700, y: 800) this didn't work for the challenge the balls wouldn't appear on the screen.
                // CGPoint(x: 200, y: 300) changing it to this CGPoint was much better but it only spawned the balls in the coordinates given...
                //creating  ball.position = ballLocation and ball location value didn't work either. Spawned balls where screen was touched not at the top of the screen.
        ball.name = "ball" //this is how we can name nodes so they're easier to find in code.
        
                
        addChild(ball)//creates ball
                
                usedBalls -= 1
                
//                if objects.contains(resetLabel){
//                    resetButton.toggle()
//                } else if usedBalls == 0 {
//                    score = 0
//                    usedBalls = 5
//                }
                
                
//                if touches.count > 5 {
//                let ac = UIAlertController(title: "Game Over", message: "Your score is \(String(describing: scoreLabel))", preferredStyle: .alert)
//                               ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: Reset))
            }
            else if noOfBalls == 0 {
                let ac = UIAlertController(title: "Game Over", message: "Your score is \(String(describing: scoreLabel))", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: Reset))
                    ac.present(ac, animated: true)
//                           
//                       }
                
            
            }
            
            //if touches.count > 5 { UIAlert Controller isn't showing....
            
            
            //changing let from ball to allBalls didn't do anything, the image named remains unchanged so its just red balls continuously.
            //creating a second ball1 constant with image name "ballBlue", same vlaues for physicsBody? restitution, contactTestBitMaks, collision and location didn't work. For some reason it just changed the colour to blue when it hit the slotBase...must be because of the collision function.
            //third attempt using   var balls: [SKSpriteNode] = []
                          //let noOfBalls = 6
                      
                          //for _ in 0..<noOfBalls { } had an interesting outcome. It made the one ball turn into 6 when hitting a bouncer from the let noOfBalls constant. balls.append(contentsOf: allBalls) allowed me to add the array but not the colors as the image name is still the same.
            
            // let ball = SKSpriteNode(imageNamed: "\(allBalls)") this just dropped a bunch of boxes with Xs in them
            
    }
        
        
        
    }
    
    
    
    func makeBouncer(at position: CGPoint) {
            let bouncer = SKSpriteNode(imageNamed: "bouncer")//from Assets
                   bouncer.position = position //not CG Float and coordinates x256 and y0 because that just creates the bouncer in one place.
                   bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
                   bouncer.physicsBody?.isDynamic = false // object will collide with other objects
                   addChild(bouncer)
        }
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode// allows a glow to the slotbases
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
            
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad" //don't forget to rename to the opposite. This was labelled as "good" so the score kept going up even when it hit a bad slotBase. Changed it to "bad" and now it works.
        }
        slotBase.position = position
        slotGlow.position = position //don't forget to initialise it here
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false //don't want the slotBases to move when they are hit by another object.
        addChild(slotBase)
        addChild(slotGlow)//and addChild so it shows up in game
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
     
     func collision(between ball: SKNode, object: SKNode) {//called when a ball collides with another object
        if object.name == "good" {
            destroy(ball: ball) //destroys object
            score += 1
            usedBalls += 1 // ok so this added balls when it hit the good slotBase
            
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }//simple way to add the score depending on the collision. Like in previous projects
    }
    
    func destroy(ball: SKNode) {
        //FireParticles is an .sks file so to get it to work, we needed to drag it from our folder to the actual project folder in swift on the left.
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {//creates high performance particle effects.
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        
        ball.removeFromParent() //removes balls from the game.
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        //bug where contact.bodyB was accidentally written as contact.bodyB. made the change now it works fine.
        //guard let because if the other object has been removed since the collision has happened, don't continue running the code.
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
        
        
        //refactored this into the above
//        if contact.bodyA.node?.name == "ball" {// if first body is the ball we'll call collision between the ball and the other object. same as below
//            collision(between: contact.bodyA.node!, object: contact.bodyB.node!)
//        } else if contact.bodyB.node?.name == "ball" {
//            collision(between: contact.bodyB.node!, object: contact.bodyA.node!)
//        } now when running in the sim, the balls dissapear when they hit the slotBase.
    }
    @objc func Reset(action: UIAlertAction) {
        if usedBalls < noOfBalls {
            score = 0
            usedBalls = 5
            
        }
    }
    
    
}

//        let box = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64))// creates box to show where touch happened on screen
//        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))// gives physics body that matches the size of the box itself
//        box.position = location //set position to location
//        addChild(box) //create box

