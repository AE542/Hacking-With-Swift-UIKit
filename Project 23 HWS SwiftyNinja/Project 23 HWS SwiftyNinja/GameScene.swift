//
//  GameScene.swift
//  Project 23 HWS SwiftyNinja
//
//  Created by Mohammed Qureshi on 2021/01/02.
//

//remember set up for iPad. delete Action.sks, delete 'hello world' text from GameScene.sks, resize to 1024x768, set anchor point to 0 for both, then delete all the code apart from the didMove func
import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    enum ForceBomb {
        case never, always, random
    }
    //enum to specify what enemy comes up first
    
    enum SequenceType: CaseIterable {// CaseIterable is a type that provides a collection of all its values.
        case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain, ultraFast
        //oneNoBomb = enemy that's not a bomb
        //one = might be a bomb
        //twoWithOneBomb = one is a bomb and two aren't
        //two, three, four are random enemies
        //chain, is a link of them all and fastChain is just a faster version.
        //ultraFast for challenge 2
    }
    
    
    var gameScore: SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }//as usual use a property observer to manager the score changes
    }
    
    var livesImages = [SKSpriteNode]() //array of SKSpriteNode Objs
    var lives = 3
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    //slice node shapes
    
    var activeSlicePoints = [CGPoint]()
    //array of slices when they are added to the screen
    
    var isSwooshSoundActive = false
    //set to false as default
    
    var activeEnemies = [SKSpriteNode]()
    //tracks all active enemies in the game scene
    
    var bombSoundEffect: AVAudioPlayer? //has to be an optional
    
    var popUpTime = 0.9
    //amount of time between enemy being destroyed and created
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0 //how long to wait if the sequence type is chain or fastChain
    var nextSequenceQueued = false
    
    var isGameEnded = false //initialize here
    

    
    

    override func didMove(to view: SKView) {
    let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x:512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6) //sets gravity let than earth default (-9.8) items stay in the air longer
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        //create first sequence for bombs to run at the start of the game.
        
        
        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
            //this allows the game to throw up enemies at random.
            //allCases will automatically be created with a randomElement to pull out a random item from the enum. HOWEVER we need to make sure the enemies are removed after they leave the screen.
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
            //called after 2 seconds have passed
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0 //triggers property observer to give the label a score of 0 by default
        }
    
    func createLives() {
        //this will create 3 SKSprite nodes and create them at the top of the screen to manage the lives.
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720) //834 is edge of screen. i*70 part means that 0 x 70, 1 x 70, 2 x 70 to push the sprites to the right consecutively
            addChild(spriteNode)
            livesImages.append(spriteNode)// appends to the livesImages array.
        }
        
    }
    
    func createSlices()  {
        // creates the glowing slices when the player swipes the screen to cut
        //1. track the players movements on the screen tracking recording an array of their swipe points.
        //2. draw 2 slice shapes one in white and another in yellow
        //3. use zPosition property to make sure the slices go above everything else in the game.
        activeSliceBG = SKShapeNode()//initialise
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode() //cannot assign skshapenode.type to skshapenode error, because not initialised with parens.
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1) //yellow
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
        
        //now need to add touchesBegan, touchesMoved and touchesEnded.
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }
        //makes sure the game has ended.
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location) //tell us all the nodes under the user's finger right now
        
        for case let node as SKSpriteNode in nodesAtPoint {
            //will now only enter the loop if the node it finds inside is an SKSprite node.
            if node.name == "enemy" {
                //destroy penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                //need to happen at the same time
                let group = SKAction.group([scaleOut, fadeOut]) //needs to be wrapped in a sequence as so below
                
                let seq = SKAction.sequence([group, .removeFromParent()]) //run group first then destroy the node
                node.run(seq)
                
                //action group specifies all actions inside it should run simultaneously
                //sequence group runs actions one at a time.
                
                
                
                
                score += 1
                //need to find where enemy is in the activeEnemies array and remove it. Example code:
                if let index = activeEnemies.firstIndex(of: node ) {
                    activeEnemies.remove(at: index)
                    //this is one way of doing this, by typecasting as an SKSpriteNode. This is safe because the node name is enemy here.
                    //The better method is:
                    //can use for case let as above. This way we don't need to force downcast and the for case let does the typecast instead for us.
                    
                }
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
                
                
            } else if node.name == "bomb" {
                //destroy bomb
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                //if we can't read the node.parent as an SKSpriteNode, bail out immediately and move on to the next item (continue)
                if let emitter = SKEmitterNode(fileNamed: "sliceBombHit") {
                    emitter.position = bombContainer.position
                    addChild(emitter)// add to game scene
                }
                
                node.name = "" //clear the sprite so we can't hit the bombs twice.
                bombContainer.physicsBody?.isDynamic = false
                //disables physics on the bomb container itself.
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                //need to happen at the same time
                let group = SKAction.group([scaleOut, fadeOut]) //needs to be wrapped in a sequence as so below
                
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)// same as the code above but this time we;re gonna run the bombcontainer as a sequence.
                    //find it in activeEnemies array as before and remove it
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
                endGame(triggeredByBomb: true)
                //cannot find triggeredbyBomb in scope means incorrect method used here. Should use colon : not =
                //need to adjust update game method. As it is, when a penguin or a bomb falls from the scene, if a player misses a penguin they lose a life and delete the nodes name to avoid any problems
            }
        }
    }
    
    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return }
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        addChild(gameOver)
      
        
        let finalScore1 = SKLabelNode(text: gameScore.text)
        finalScore1.fontName = "Chalkduster"
        finalScore1.fontColor = .white
        finalScore1.fontSize = 40
        
        finalScore1.position = CGPoint(x: 512, y: 300)
        finalScore1.zPosition = 2
        addChild(finalScore1)
        //same code as in project 14, works like a charm here.
        
        isGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        //stops the user from pressing on the screen and continuing the game
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        //stops bomb soundeffect and destroy it
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")        }
    }// have to use the parameter here. texture will change to a red cross.
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        //starts by setting the var to be true, then play one of the three swoosh sounds.
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        //wrap inside an SKAction
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        //SKAction will wait until its finished before triggering its completion closure.
        
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
            //run this completion closure as a weak self. Stops it playing more than one swoosh sound at one given time.
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        activeSlicePoints.removeAll(keepingCapacity: true)
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        activeSliceFG.removeAllActions()
        activeSliceBG.removeAllActions()
        //ends and removes all actions from node.
        
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
        //when touches ended is called, we want these nodes to fade out and remove it when the action is finished.
    }
    
    func redrawActiveSlice() {
        //use UIBezierPath to make a curve.
        if activeSlicePoints.count < 2 { //cannot convert type of cg point to Int because not an int without adding .count
            //if slice point are less than 2, clear the shapes and exit the method.
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
            //removes the amount of active slice points - 12 e.g. if 15 it will subtract at -12 = 3  = remove first 3 items
            
        }
        
        let path = UIBezierPath()
            path.move(to: activeSlicePoints[0]) //variable used within its own value error. Put inside its own closure { } which was wrong.
        //go to very first slice point on the screen
                //now loop from 1 up to excluding activeSlicePoints.count
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        activeSliceBG.path = path.cgPath //cannot assign value of type CGPath to SKShapeNode because didn't assign type of .path to activeSliceBG
        activeSliceFG.path = path.cgPath
        
        //now need to manage the sounds isSwooshSoundActive and we need to use a completion closure to handle it if its false, to allow only one swoosh sound is playing at a time.
        
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {// takes one param forcebomb an instance of the ENUM above with a default of .random
        let enemy: SKSpriteNode
        let superEnemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...6) //allows random distribution if its a bomb or penguin
        
        if forceBomb == .never { // this is definitely not a bomb
            enemyType = 1
            
            
        } else if forceBomb == .always {
            enemyType = 0
          
        }
            if enemyType == 0 {
                //bomb code goes here
                
                enemy = SKSpriteNode()//container to hold
                enemy.zPosition = 1
                enemy.name = "bombContainer"
                
//                superEnemy = SKSpriteNode()
//                superEnemy.zPosition = 2
                
                let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
                bombImage.name = "bomb"
                enemy.addChild(bombImage) //added to contatiner node.
                //superEnemy.addChild(bombImage)
                
                if bombSoundEffect != nil {
                    bombSoundEffect?.stop()
                    bombSoundEffect = nil
                } //made and played from scratch everytime.
                
                if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {//find sound file in our bundle, if succeeds we can let it load in AVAudioPlayer
                    if let sound = try? AVAudioPlayer(contentsOf: path) {
                        bombSoundEffect = sound
                        sound.play()
                    }
                
                }
                if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                    //emitter.position = CGPoint(x: 76, y: 64)
                    emitter.position = K.emitterPosition
                    //for the challenge, made a struct to hold the constants like I did in flashchat seems to work...
                    enemy.addChild(emitter)
                    //forgot to add the SKEmitterNode to the actual bomb here. Now it shows in game.
                }
                
            } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
                
//            superEnemy = SKSpriteNode(imageNamed: "penguin")
//                run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
                
        }
        //position code goes here. Gives random x, y velocity and set collision bit mask so they don't collide.
        let randomPosition = K.randomPosition
        enemy.position = K.randomPosition
        //superEnemy.position = K.randomPosition
        
        //let randomAngularVelocity = CGFloat.random(in: -3...3)
        let randomAngularVelocity = K.randomAngularVelocity
        //for challenge 1
        let randomXVelocity: Int //for movement speed
        
        if randomPosition.x < 256 { //if way to left of the screen we'll make it high so it moves to the left
            randomXVelocity = Int.random(in : 8...15)
                
        } else if randomPosition.x < 512 { //if to the right it will move right
            randomXVelocity = Int.random(in: 3...5) //move to left slowly
        } else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...5) //didn't know you could do -Int. This allows it move left from the far right of the screen.
        } else {
            randomXVelocity = -Int.random(in: 8...15)// used before initialized error because this part was missing.
        }
        //these were found through trial and error
        //let randomYVelocity = Int.random(in: 24...33)
        let randomYVelocity = K.randomYVelocity
        //for challenge 1
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)//half size of sprite
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        //Constant 'randomXVelocity' used before being initialized error because the if randomPosition.x < 256 method wasn't finished properly. Missing an else statement to add the randomXVelocity and initialise the int.
        
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0//
        
        //now need to make the bomb's logic
        //need to keep the bomb and bomb fuse seperate to stop the user from losing lives unfairly.
        //needs to play its own fuse sound. We need to be able to stop the sound when the bomb dissapears. We can use AVAudioPlayer here to accomplish this.
        
        addChild(enemy)
        
//        superEnemy.physicsBody = SKPhysicsBody(circleOfRadius: 48)
//        superEnemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 80, dy: randomYVelocity * 40)
//        addChild(superEnemy)
        
        activeEnemies.append(enemy)
        //activeEnemies.append(superEnemy)
        //constant enemy used before intialized because if enemy type is 0 (bomb code goes here will be called) it won't have a value by the time it reaches add child. Need to add bomb code. Better to use constants with names.
    }

    //this createEnemy func only creates 1 enemy! So we need to create a new func to handle multiples. First make a new global enum above.
    
    
//    func superEnemy(forceBomb: ForceBomb = .random) {
//        let superEnemy = SKSpriteNode()
//
//        var superEnemyType
//
//
//
//    } //better to just add the details of the super enemy to the createEnemy func.
    
    func subtractLife() {
        lives -= 1
        run(SKAction.playSoundFileNamed("wrong", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]//handles the array of images for lives.
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to:1, duration: 0.1)) //becomes big immediately, then scales down straight after
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if activeEnemies.count > 0 {
            //need to loop through the activeEnemies array inverse and pull out the enemies from the array.
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
//                    node.removeFromParent()
//                    activeEnemies.remove(at: index)
                    node.removeAllActions()
                    if node.name == "enemy" {
                        node.name = "" //clear nodes name so its an empty string.
                        subtractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer"{
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                        //same across all cases expect when subtracting lives.
                        
                    }
                }
            }//if have active enemies currently and below -140, remove from activeEnemies array. If none, schedule next sequence to add more enemies.
            
        } else {// no activeEnemies + next sequence is NOT queued
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popUpTime) {
                    [weak self] in
                    self?.tossEnemies()
                }
                nextSequenceQueued = true
                //don't need to call toss enemies again and again as nextSequence is called.
            }
            }
        
        
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {// adds bomb to container and allows the sound to play for the fuse.
                bombCount += 1
                break
            }
        }
        if bombCount == 0 {
            //no bombs - stop the fuse sound!
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    func tossEnemies() {
        guard isGameEnded == false else { return }
        //lets not make any more enemies if the game is over.
        //this func creates multiple enemies on screen. Increase the speed of the physicsWorld so enemies and rise and fall faster
        popUpTime *= 0.991
        chainDelay *= 0.99// decrease both this and popUpTime
        physicsWorld.speed *= 1.02
        
        //read current sequence position from array
        
        let sequenceType = sequence[sequencePosition]
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never) // remember this calls the forceBomb's enum values in the param here from
        case .one:
            createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            createEnemy()
            createEnemy()
            
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
            //now we have to use GCD's async after method to create an enemy over a period of time.
        
        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) {
                [weak self] in self?.createEnemy() }// when this runs, we use TCS, with a weak self and create an enemy after 1/5th of our chain delay and then multiply the result by 2, 3, 4 times so they're spaced out over a few seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0) * 2) {
                [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0) * 3) {
                [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0) * 4) {
                [weak self] in self?.createEnemy() }
            
        case .fastChain: // now we divide the chainDelay by 10 to increase the speed of which enemies are generated.
            createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) {
                [weak self] in self?.createEnemy() }// when this runs, we use TCS, with a weak self and create an enemy after 1/10th of our chain delay and then multiply the result by 2, 3, 4 times so they're spaced out over a few seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0) * 2) {
                [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0) * 3) {
                [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0) * 4) {
                [weak self] in self?.createEnemy() }
            
        case .ultraFast:
            createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 15.0)) {
                [weak self] in self?.createEnemy() }
            
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
        } //we don't a have a call to toss enemies in the pipeline waiting to execute. It means'I know there aren't enemies right now but more will come shortly'
}
