//
//  GameScene.swift
//  HWS Project 29 Exploding Monkeys
//
//  Created by Mohammed Qureshi on 2021/02/24.
//

//Using Atlases is quite simple, first go to the Assets folder and then right click AR and SceneKit to get the Atlas loaded up. Then we can just drag and drop for example.png assets like we do for a regular project in to the Sprites folder.

import SpriteKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
    
    //need to destroy banana if it hit building or hits player. We need to show the impact point where the banana lands.
    
} //this handles the types so we can make calculations depending on which object was hit in the game.


//may need to set a did set property observer here like in previous projects.

var gameViewController = GameViewController()


var player1score = 0 {
    didSet {
        gameViewController.player1Score?.text = "Player 1 Score: \(player1score)"
    }
}

var player2Score = 0 {
    didSet {
        gameViewController.player2Score?.text = "Player 2 Score: \(player2Score)"
    }
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    //need physicsContactDelegate to allow destructible environment.
    var buildings = [BuildingNode]()
    
    weak var viewController: GameViewController? //weak var to avoid strong ref cycles
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1 // handles which player is taking their turn
    
    
    override func didMove(to view: SKView) {
        //need to create night sky for the background and the buildings themselves here
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        createBuildings() //needs to fill the screen from each edge of the screen with building objects
        createPlayers() // now we can load the players in by calling it here.
        
        physicsWorld.contactDelegate = self // to allow methods for contact between objects.
        
}
    func createBuildings() {
        var currentX: CGFloat = -15 //15 points away from edge of the screen. Should be = not -, and -15 offset NOT 15.
        
        while currentX < 1024 { //current x less than the right edge of the screen
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))//can be 80, 160 or 240
            currentX += size.width + 2 //move along current x value and give space between building nodes. SHOULD BE + NOT *
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2) //buildings are centered on the middle of themselves. We can move them across by half the width to offset the center point anchoring.
            //was x: currentX - size.width - 2 which was creating an error where the buildings appeared behind each other.
            building.setup()
            addChild(building)
            buildings.append(building)
            //now the buildings are created randomly when the game loads.
        }
    }
    
    func launch(angle: Int, velocity: Int) {
        //figure out how hard to throw the banana, figure out the angle and radius to throw.
        let speed = Double(velocity) / 10 //typecast Double as Int here as 1/10th of the velocity
        let radians = degToRad(degrees: angle)
        
        
        //need to destroy the banana if there's more than one on the screen.
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        banana = SKSpriteNode(imageNamed: "banana")
        //fatal error NIL because the SKSpriteNode was not named correctly! Should be imageNamed not fileNamed which triggered the nil error.
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue //you only need one | to have an OR declared here not two || like in a func
        //banana, building and the player are all of type UInt32 as they are declared in the enum above.
        banana.physicsBody?.applyForce(CGVector(dx: 200, dy: 0))
        //applies force to the objects (node's) center of gravity
        
        //to avoid the banana passing through a building or a player we can use this:
        banana.physicsBody?.usesPreciseCollisionDetection = true
        //will perform calculations between objects but is slow so don't use on large objects.
        addChild(banana)
        
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y - 40) //y position so the player doesn't accidentally drop the banana on themselves.
            banana.physicsBody?.angularVelocity = -20 //so it slows down when thrown at an angle.
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            // just like in the previous projects we need to put the actions in a sequence to get them to work
            player1.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else if currentPlayer == 2 {
                banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40) //y position so the player doesn't accidentally drop the banana on themselves.
            //have to change values to + here for player 2
                banana.physicsBody?.angularVelocity = -20 //so it slows down when thrown at an angle.
                
                let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
                let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
                let pause = SKAction.wait(forDuration: 0.15)
                
                let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
                // just like in the previous projects we need to put the actions in a sequence to get them to work
                player2.run(sequence)
                
                let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            //we have to change the speed to -speed here so it can be thrown at the correct angle for player 2
            
            //sin cos tan again very basically:
//            Sin is equal to the side opposite the angle that you are conducting the functions on over the hypotenuse which is the longest side in the triangle. Cos is adjacent over hypotenuse. And tan is opposite over adjacent, which means tan is sin/cos.
                banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func createPlayers(){
        player1 = SKSpriteNode(imageNamed: "player") //cannot assign SKSprite node player1.name to type string
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2) //makes the player sprite rounder with the circule of the radius divided by 2
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false //don't let the player move around with gravity off
        
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height ) / 2))
        //position.x = center position on the center of the building. The y: division part gets the building and player height and divides the amounts by 2 so they all stay centered. The player being in the center of the building.
        addChild(player1)
        
        player2 = SKSpriteNode(imageNamed: "player") //cannot assign SKSprite node player1.name to type string
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2) //makes the player round
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false //don't let the player move around with gravity off
        
        
        //YOU FORGOT TO ADD collisionBitMask and contactTestBitMask so the players wouldn't explode when the banana's hit them. Now they do.
        
        let player2Building = buildings[buildings.count - 2] //place player 2 at the SECOND to last building.
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player1.size.height ) / 2))
        //position.x = center position on the center of the building. The y: division part gets the building and player height and divides the amounts by 2 so they all stay centered. The player being in the center of the building.
        addChild(player2)
        
        //need to use texture atlases. An Atlas is a set of pictures combined into a single image. Atlas also contains positions and sizes. SpriteKit loads the whole atlas. It crops the image automatically. Xcode deals with this automatically.
    }
    
    //this func needs to handle the maths for calculating the degree and the radius the banana is thrown
    func degToRad(degrees: Int) -> Double {
        return Double(degrees) * .pi / 180 //don't need to write degrees: Int as its extraneous we only need to call the param name.
        //this func can now be called in the launch method
}
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        //we need these guard lets because if the values are nil we need to bail out. Collision has already been handled.
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
            player2Score += 1
            
        }
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
            player2Score += 1
        }

    }
    
    
    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController?.currentGame = newGame //the new game scene points to the vc then it points back to the game scene
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer //second player takes over if the first player has won vice versa
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
        
    }
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        //remember the node checking above to confirm a building node has been collided with
        guard let building = building as? BuildingNode else { return }
        let buildingLocation = convert(contactPoint, to: building) //need to convert the point into the coordinate space of the building node.
        building.hit(at: buildingLocation) //update texture by destroying the part the banana hit
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        banana.name = "" //if banana hits 2 buildings at the same time it will explode twice and call the changeplayer twice giving the player another throw. Clearing the banana's name here makes the didBegin method unable see it as being a banana. Only the first collision happens.
        banana.removeFromParent()
        banana = nil
        changePlayer()
    }
    
    func changePlayer() {
    if currentPlayer == 1 {
    currentPlayer = 2
    } else {
        currentPlayer = 1
    }
        viewController?.activatePlayer(number: currentPlayer) //shows the correct player in the UIKit layout.
}
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()//must call this so the player can then switch if the banana misses
        }
    }
}
