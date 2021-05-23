//
//  GameScene.swift
//  Project 20 HWS Fireworks Night
//
//  Created by Mohammed Qureshi on 2020/12/10.
//

import SpriteKit

//remember clean up before creating iPad games
//delete Action.sks, change GameScene.sks size to 1024x768, and Anchor Point to 0 for x and y positions.
//When adding files remember pngs go in the Assets folder and .sks files outside of it.

class GameScene: SKScene {
  
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var scoreLabel: SKLabelNode! //remember it should be an optional because their might not be a score in there.
    
    
    var challengeTimer = 0.0
    var launches: Int = 0 {
        didSet {
            if launches == 10 {
                gameTimer?.invalidate()
                //gameTimer = Timer.scheduledTimer(timeInterval: challengeTimer, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: false)
            //print("launches\(launchFireworks())")
                //solution was even simpler than I thought. Just creating a launches Int and a didSet property to manage the launches makes them invalidate after 10. Adding the launches to the createEnemy func solved this. No need to create an extra timer as it accidentally fires off at the same time as the original gameTimer. 
        }
    }
    }
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background") //from assets folder
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace //source colour replaces destination colour.
        background.zPosition = -1
        addChild(background)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        //creating fireworks that launch every 6 seconds so we need to use the timer.
        
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16) //bottom left corner of screen
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0 // just like in project 17 this worked for getting the score label to show in the bottom left corner. You need to write score = 0 to initialise the property observer above (var score = 0 didSet { } method)
}
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1 //colour by the full amount of colour specified.
        firework.name = "firework"
        node.addChild(firework) //now we add it the firework TO the NODE so it will move with fuse.sks
        //
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan //can recolour sprites dynamically. The rocket is actually just white but we can change it here.
        case 1:
            firework.color = .green
        case 2:
            firework.color = .blue
        default:
            firework.color = .red
        } // this switch method randomly chooses the colour in the defined cases.
        
        let path = UIBezierPath()// determines path where the sprite moves can be curved, straight etc.
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000)) //creates path we want it to follow.
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        fireworks.append(node)// add to firework node array
        addChild(node) //add to GameScene
        //Now the fireworks have the fuse.sks added to the bottom of them.
    }
    
    @objc func launchFireworks() {
        //var launches: Int = 50
        launches += 1
        // kind of worked for challenge 2
        //actually worked for challenge 2! you needed to add and append the launches here and increase by 1. The didSet property observer handled it above.
        let movementAmount: CGFloat = 1800 //guideline, can be different numbers but this works the best
        
        switch Int.random(in: 0...3) {
        case 0:
            //fire five straight up
            
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200 , y: bottomEdge)
        //0 goes straight up and 512 is in the middle of the screen. Bottom edge is -22 as declared above.
            
            //attempted for loop might return to just 5 lines of code.
        //didn't work only did the loop once. Will try again later.
        case 1:
            //fire five in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
            // - numbers go to the left + numbers go to the right
        
        case 2:
            //fire five from left to right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            //fire five from right to left.
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
            
//        case 4:
//            gameTimer?.invalidate()
        default:
            break //loop
        // we can add more firework display cases here later
        }
        //launches += 1
        print(launches) //this showed the launches but wouldn't show any the fireworks launching anymore.
    }
    //main method to make 1 firework, create skNode that handles the firework and the sks firework file
    //create rocket sprite node. Can adjust colour blend factor to tint sprites with different colours.
    
    func checkTouches(_ touches: Set<UITouch>) { //same as touches began and moved
        guard let touch = touches.first else { return } //bail out if touches could not be found for any reason.
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            //node.colorBlendFactor node is just a regular node not an SKSpriteNode. We want to typecast each node as an SKSpriteNode.
            //for case let node. It will create a new constant called an SKSpriteNode and uses a case (true/false) if it succeeds, run the loop.
            guard node.name == "firework" else { continue } //get out of loop if dealing with anything that's not a firework
            
            //inner loop needs to make sure the player can only select one colour at a time and deselect if a different colour is selected.
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue } //means exit loop immediately if we can't find the sprite node in the parent node.
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0 //makes the node go back to white
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    //update method needs to be created to handle fireworks player doesn't destroy
    //when removing items from an array we need to remove them backwards as when you remove an item it renumbers the items in the array
    
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//    }
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
                
//                if fireworks.count == 20 {
//                    gameTimer?.invalidate()
//                }
                //this removes the fireworks we don't touch in game.
//            } else if fireworks.count == 20 {
//                gameTimer?.invalidate()
//            }//didn't seem to invalidate the timer.
//        } else if fireworks.count == 10 {
//            gameTimer?.invalidate()
                
            }//setting fireworks.count == 5 invalidated the timer. Setting to 10 didn't it kept looping.
        }
        //gameTimer?.invalidate() completely stopped the game
        
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            //let explodeParticleLife = emitter.particleLifetime = 0.6
//            let waitAction = SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime))
//            emitter.run(waitAction, completion:emitter.removeFromParent )
            addChild(emitter)
            
            let waitAction = SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime))
            emitter.run(waitAction, completion:emitter.removeFromParent )
            //emitter.removeChildren(in: [firework]) for challenge 3 but doesn't work here.
            //emitter.removeFromParent()
            //this seems to be the solution for challenge 3 but not sure if its working. Found on StackOverflow.

        }
                //emitter.particleBirthRate = 2048
        
        
        
        //let explosion = SKAction.init(named: "explode")
//        let explosion = SKEmitterNode.init(fileNamed: "explode")
//        if let emitter = SKEmitterNode(fileNamed: "explode") {
        //}
        
//        explosion?.removeFromParent()
        firework.removeFromParent()
        
        
    }
    //need to loop backwards through the fireworks array when they are destroyed. Fireworks array needs to be read from its children array to see if its selected or not
    func explodeFireworks() {
        var numExploded = 0
        
        for(index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue } //if fails go to next item in the array
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)

                numExploded += 1
                
//            } else if numExploded == 20 {
//                gameTimer?.invalidate() //didn't invalidate the game timer.
            }
            
                    if let emitter = SKEmitterNode(fileNamed: "explode") {
                        let waitAction = SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime))
                        emitter.run(waitAction, completion:emitter.removeFromParent )
                    }
            //if (firework.action(forKey: "explode") != nil) {
                
           // }
            //wasn't the solution for challenge 3
//            if fireworks.count == 20 {
//                gameTimer?.invalidate()
//            }// wasn't the solution. Using a variable with a property observer worked way better. As above.
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
            //this handles the score multiplier if you hit the correct fireworks in a row
          //now need to detect when iPad is shaken but this method needs to be declared in GameVC
        }
    }
}
