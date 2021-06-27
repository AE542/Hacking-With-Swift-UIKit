//
//  GameScene.swift
//  Project 26 HWS Marble Maze
//
//  Created by Mohammed Qureshi on 2021/01/14.
//
//set the ipad's orientation to be landscape left only as we can move the marble around without the game auto orienting the screen.
//as always set gamescene's size to 1024 x 768 for iPad. Delete Action.sks and most of the code apart from didMove(to view:)
//the level1.txt file has the game's level layout already created in txt format. X being the walls, V being the Vortexes, S being the Stars and f being the finish.

// things I remembered in this lesson:
//addChild(node) is necessary for ALL SKSpriteNodes otherwise they don't show up in the game scene
//right click and refactoring the name of constants (here it was the node name), and selecting rename allows you to change the name of all the instances of that name in its closure.

import CoreMotion //so we can use the accelerometer

import SpriteKit
import UIKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case teleporter = 7//for challenge 3
    case vortex = 8
    case finish = 16
    //these values can combine to get a new number. For example if you add vortex, star and wall you'lll get 14. Which is a unique enum type with a value of 14 that represents these combination of game objects.
    //if player and finish it will = 17 which means the game is finished. We can double the number this way.
    
    //CAREFUL! ENUMS SHOULD BE ABOVE THE CLASS IN THE VIEW HIERARCHY! This was why the background constant was coming up as optional.
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    //need to create a method that handles the player's movements
// set the physicsbody allows rotation to false. Useful as reflections of ball won't reflect if rotating
    //2. give linear damping value of 5 to slow down the ball
    //3. combine the three values together to get the ball's contactTestBitMask
    var lastTouchPosition: CGPoint?
    
    var motionManager: CMMotionManager? //expected name or constructor type error again you need to initialise the type with colons : not =
    //now have to create an object to collect the data from the accelerometer
    var isGameOver = false
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet { //remember didSet updates the scorelabel when the score value changes.
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
    //now we can load the data from below here to allow the game scene to work.
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace //source colour replaces the destination colour
        background.zPosition = -1 //just behind the other objects
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        
        loadLevel()
        
        createPlayer()
        
        physicsWorld.gravity = .zero
        
        physicsWorld.contactDelegate = self //tell us when a collision happens.
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        //now it will collect the data from the accelerometer
    }//unwrap with an if let hopefully it will work and get rid of the optionals. didn't work
        
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else { fatalError("Could not find the level1.txt in the app bundle")}//if not level URL bail out immediately
        //Class property 'main' is not a member type of 'Bundle' use = NOT :
        //we should really use a fatal error function here because the code will silently fail here if there's any problems with the text here. So we can replace return with fatal error here to catch it...didn't know you could have a fatal error return in a guard let here.
        guard let levelString = try? String(contentsOf: levelURL) else { fatalError("Could not load contents of levelURL(level1.txt) from app bundle") }
        // if can't load level string from level url, bailout.
        //same as above replace return with fatal error
        
        let lines = levelString.components(separatedBy: "\n") //put a space between each character.
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                //should have been line.enumerated not lines otherwise value isnt used error comes up!
                //also stopped the fatalError being triggered below. saying unknown file:xxxxxxx found when the letter wasnt x, v,
                //reversed reads from bottom to top in an inverted y axis
                let position = CGPoint(x: (64 * column) + 32, y:(64 * row) + 32)
                //why this calculation? We need to do this so we can offset for the center in SpriteKit.
                
                switch letter {
                case "x":
                loadWall(position: position)
                
                case "v":
                loadVortex(position: position)
                    
                case "s":
                loadStar(position: position)
                
                case "f":
                loadFinish(position: position)
                    
                case " ":
                loadEmptySpace(position: position)
                default :
                    fatalError("Unknown level letter: \(letter)")
                }
                //ok the app didn't explode when changing this to a switch statement and making setting param value to be the position...
                
                
                
//                if letter == "x" {
//                    //load a wall
//                    let blockNode = SKSpriteNode(imageNamed: "block")
//                    blockNode.position = position
//                    blockNode.physicsBody = SKPhysicsBody(rectangleOf: blockNode.size)
//                    blockNode.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue //we have to use a rawValue to extract the value from wall which is an enum of type UInt32
//                    blockNode.physicsBody?.isDynamic = false//turn off physics actions for this node.
//                    addChild(blockNode) //still need to add this to the child? Yes! You needed to add this to get the walls to show up.
//
//                } else if letter == "v" {
//                    //load vortex
//                    let vortexNode = SKSpriteNode(imageNamed: "vortex")
//                    vortexNode.name = "vortex"//better to name this here so we know what node this is when we have collisions.
//                    vortexNode.position = position
//                    vortexNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))//allows the node to keep spinning for a duration of 1 second moving by pi
//                    vortexNode.physicsBody = SKPhysicsBody(circleOfRadius: vortexNode.size.width / 2)
//                    vortexNode.physicsBody?.isDynamic = false
//                    vortexNode.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
//                    vortexNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue //want to be notified when the node touches the player.
//                    vortexNode.physicsBody?.collisionBitMask = 0 //bounce off nothing
//                    addChild(vortexNode)
//                } else if letter == "s" {
//                    let starNode = SKSpriteNode(imageNamed: "star")
//                    starNode.name = "star"
//
//                    starNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 2)))//want to try having a rotating star
//                    starNode.physicsBody?.isDynamic = false
//                    //load star
//                    starNode.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue //be careful when assigning the collision type should be the same as the SKSpriteNode
//                    starNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
//                    starNode.position = position
//                    addChild(starNode)
//                } else if letter == "f" {
//                    //load finish
//                    let finishNode = SKSpriteNode(imageNamed: "finish")
//                    finishNode.name = "finish"
//                    finishNode.position = position
//                    finishNode.physicsBody = SKPhysicsBody(circleOfRadius: finishNode.size.width / 2)
//                    finishNode.physicsBody?.isDynamic = false
//
//                    finishNode.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
//                    finishNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
//                    finishNode.physicsBody?.collisionBitMask = 0
//                    finishNode.position = position
//                    addChild(finishNode)
//
//                    //note for challenge, it might be better to refactor this code by making a struct to handle each of the changes and just pass it back to to the gameScene so the code we don't have to rewrite this over and over again for each node.
//                } else if letter == " " { //must be an empty space here
////                    let backgroundNode = SKSpriteNode(imageNamed: "background")
////                    backgroundNode.name = "background" //can't add a node because we just need to add an empty space
//                    //we just want this to do nothing
//
//                } else {
//                    fatalError("Unknown level letter: \(letter)")
//                    //fatal error triggered when the first time we loaded the app in the simulator. Because there's a value that not a letter
//                    //Unknown level letter: xxxxxxxxxxxxxxxx: file. we missed out the empty space here!
//                }
                //we now need to use the fatal error function from project 10
                //categoryBitMask is the number that defines the type of object this is for collisions
                //collisionBitMask defines what categories an object collides with.
                //contactTestBitMask = which collisions we want to know about.
                //player has vortex star and finish set with contactBitMask.
                //We need to use enums with raw values. We can refer to the options with names instead of numbers this way
            }
        }
    }
    
    func loadWall(position: CGPoint) {
        let blockNode = SKSpriteNode(imageNamed: "block")
        blockNode.position = position
        blockNode.physicsBody = SKPhysicsBody(rectangleOf: blockNode.size)
        blockNode.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue //we have to use a rawValue to extract the value from wall which is an enum of type UInt32
        blockNode.physicsBody?.isDynamic = false//turn off physics actions for this node.
        addChild(blockNode)
    }
    
    func loadVortex(position: CGPoint) {
        let vortexNode = SKSpriteNode(imageNamed: "vortex")
        vortexNode.name = "vortex"//better to name this here so we know what node this is when we have collisions.
        vortexNode.position = position
        vortexNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))//allows the node to keep spinning for a duration of 1 second moving by pi
        vortexNode.physicsBody = SKPhysicsBody(circleOfRadius: vortexNode.size.width / 2)
        vortexNode.physicsBody?.isDynamic = false
        vortexNode.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        vortexNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue //want to be notified when the node touches the player.
        vortexNode.physicsBody?.collisionBitMask = 0 //bounce off nothing
        addChild(vortexNode)
    }
    
    func loadStar(position: CGPoint) {
        let starNode = SKSpriteNode(imageNamed: "star")
        starNode.name = "star"
     
        starNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 2)))//want to try having a rotating star
        starNode.physicsBody?.isDynamic = false
        //load star
        starNode.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue //be careful when assigning the collision type should be the same as the SKSpriteNode
        starNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        starNode.position = position
        addChild(starNode)
    }
    
    func loadEmptySpace(position: CGPoint) {
        //don't need this to do anything like in the if else statement in loadView.
    }
    
    func loadFinish(position: CGPoint) {
        let finishNode = SKSpriteNode(imageNamed: "finish")
        finishNode.name = "finish"
        finishNode.position = position
        finishNode.physicsBody = SKPhysicsBody(circleOfRadius: finishNode.size.width / 2)
        finishNode.physicsBody?.isDynamic = false
        
        finishNode.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        finishNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        finishNode.physicsBody?.collisionBitMask = 0
        finishNode.position = position
        addChild(finishNode)
        
    }
    
    func createPlayer() {
    player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672) //positioned right for level 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)// just like for the loading the level we give it half the size of a circle
        player.zPosition = 1
        player.physicsBody?.allowsRotation = false //won't rotate the player ball
        player.physicsBody?.linearDamping = 0.5 //slows the ball down.
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue //we need to add these three types here so the ball can detect what it is colliding with. The pipe | allows us to combine these values together.
        //These are called bitwise or and it combines numbers together.
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    //we create this method as part of getting the ipad to tilt on the simulator
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
        //stops any further touch events as the user stopped touching the screen
    }
    override func update(_ currentTime: TimeInterval) {
        
        guard isGameOver == false else { return } //stops the player continuing the game when its over.
        
        #if targetEnvironment(simulator) //start simulator code only.
        if let lastKnownTouchPosition = lastTouchPosition {
            let diff = CGPoint(x: lastKnownTouchPosition.x / 100 - player.position.x, y: lastKnownTouchPosition.y / 100 - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100) //reduces size of vector
            
        } // we need this func to calculate the lastposition of x and y and divide that by 100 then minus that by the player's position. The gravity will change where the player presses on the screen. So we can speed up the ball by pressing further away and slow it when pressing closer. This isn't a permanent solution however. Better to use an actual device.
        
        #else //this is actual device code that runs on an iPad
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }//tilting has very gentle values. We don't want the player to tilt it very far. So we multiply dx by -50 and dy * 50 we need to invert it on the y axis because the ipad will be rotated.
        #endif //need to end these #if statements with #endif.
    }
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        //remember guard let makes sure conditions are correct before moving on, here if the node is anything else but a or b it will stop the code.
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    func playerCollided(with node: SKNode) { //handles game over state when player hits a vortex
        if node.name == "vortex" {
        player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            //now move the ball over the vortex to scale it like its bein sucked into it.
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to:0.0001, duration: 0.25)//reduce the size
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove]) //follows this order when method starts.
            
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            //move to next level
            
        }
    }
}
