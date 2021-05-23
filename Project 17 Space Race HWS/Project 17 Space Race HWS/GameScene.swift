//
//  GameScene.swift
//  Project 17 Space Race HWS
//
//  Created by Mohammed Qureshi on 2020/11/19.
//
//deleted GameKit and all the other code apart from the didMove and update funcs.

//GameScene.sks had no anchorpoint set to 0 so it wouldn't show up correctly on the screen. 
import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField: SKEmitterNode! //implicitly unwrapped
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    //for the obstacles in the game we need to make 3 new properties.
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer? // we'll then use this property in the didMove func. Not = use : colons so it reads the type correctly.
    
    var newTimer: Timer? //for challenge 2
    
    var isGameOver = false
    
    var runTimer = 0.0
    
    var noOfEnemies = 0 {
        didSet {
            if noOfEnemies.isMultiple(of: 20) {
                runTimer -= 0.1
                gameTimer?.invalidate()
                gameTimer = Timer.scheduledTimer(timeInterval: runTimer, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
            }// this was the solution to making a decreasing timer for Challenge 3. Very tough had to search online for a solution. The isMultiple(of:) method here is important as you could reduce timer by -0.1 when the number of enemies is a multiple of 20 e.g. 20, 40. 60. Then you invalidate the timer and run the timer again.
            //You needed to create a variable to handle the new timer.
        }
    }
    
    var score = 0 {
        didSet{ //property observer
            scoreLabel.text = "Score: \(score)"
        }//same as in previous projects.
    }//code for est. variables should be OUTSIDE of didMove. Be careful.

    override func didMove(to view: SKView) {
        backgroundColor = .black
        starField = SKEmitterNode(fileNamed: "starfield")! //must be force unwrapped. We know the file is in the assets folder already.
        //error unexpectedly found nil when unwrapping optional because sks files not in project navigator.
        
        starField.position = CGPoint(x: 1024, y: 384)// starts right edge of the screen halfway up.
        
        starField.advanceSimulationTime(10)// want to pre populate the scene with stars so we can use this to make them move across the screen in 10 seconds.
        addChild(starField)
        
        starField.zPosition = -1 //positions the starfield just behind the screen
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384) //100 points to the left and half way up the game screen
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size) //creates a physics body from a texture. Needs to be force unwrapped we know it already has a texture.
        player.physicsBody?.contactTestBitMask = 1 //allows contact with other objects remember from the previous projects.
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16) //bottom left corner of screen
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0 //use this trigger property observer didSet scoreLabel so it shows this in the text box.
        
        physicsWorld.gravity = .zero // cannot assign value of type gamescene to type skphysicscontactdelegate as not initialised in the class.
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        //gameTimer?.invalidate() //stopped enemies spawning full stop. Only call this after the necessary code block has run.
        
//        newTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//
//
//
//        }
        
        
        
        //gameTimer?.invalidate()
        
        
        
        
        //creates enemies 3 times a second.
        
        
        
        }
    
    @objc func createEnemy(){
        guard let enemy = possibleEnemies.randomElement() else { return }
        

        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736)) //random range for the y position so the items come in from different positions
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size) //texture is optional had to be force unwrapped.
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5 //allows constant speed when spinning
        sprite.physicsBody?.linearDamping = 0 //how fast an object slows down over time.
        sprite.physicsBody?.angularDamping = 0 //allows object to never stop spinning when set to 0
        

        
        
        newTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            for enemies in self.possibleEnemies {
            self.runTimer -= 0.1
            print(self.newTimer as Any)
            if enemies.count == 20 {
                
                //self.runTimer -= 0.1

                self.newTimer?.invalidate()

            }
           } //didn't seem to do anything.

        }
    
        if isGameOver == true {
            sprite.removeFromParent() // this seemed to have solved challenge 3 just removes the debris as soon as you die in game.
        }
        
    }
    
//    func decrease(_ decreaseTime: TimeInterval) {
//        for node in children{
//
//        }
//    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for node in children{
            if node.position.x < -300 {
                removeFromParent()
            }
        }
        
        
        if !isGameOver {
            score += 1
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y < 668  {
            location.y = 668
        }
        
        player.position = location //this allows the location we declared above to be the position of the rocket in the game.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // first is the first element of a collection
        let location = touch.location(in: self)
        if let explosion = SKEmitterNode(fileNamed: "explosion") {//emitter node is for particle effects.
        player.position = location
        
        explosion.position = player.position
        addChild(explosion)
        player.removeFromParent()
        
        isGameOver = true
        
        return
        }
        
        // this seems to work for challenge 1,  but the node completely vanishes...want it to explode when removing your finger.
        //ok added the explosion SKEmitterNode and now it works. Ship explodes when your finger lifts off the iPad.
        
        // need to implement may be an alert controller saying can't lift your finger up!
        }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")! // needed to be force unwrapped like starfield. Using an Force Unwrap or if or guard let can be used here.
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
    }

    
    
}
