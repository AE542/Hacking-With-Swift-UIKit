//
//  WhackSlot.swift
//  Project 14 HWS Whack-a-Mole
//
//  Created by Mohammed Qureshi on 2020/10/22.
//  Copyright © 2020 Experiment1. All rights reserved.
//

//created from Cocoa Touch Class with a subclass of SKNode.
import UIKit
import SpriteKit// SKNode comes from here

class WhackSlot: SKNode {//SKNode is parent that holds different child classes

    var charNode: SKSpriteNode!// for characters
    
    var isVisible = false // to handle if the character can be seen by the player.
    var isHit = false // default is false so its not in a hit state before the player has touched it.
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        //if you create custom init you have to create extra methods so not needed here.
        //need array for slots, create slot method, and for loops for each row.
        
        let cropNode = SKCropNode()// this allows us to hide the characters. They do use a lot of memory according to the docs so use sparingly.
        cropNode.position = CGPoint(x: 0, y: 40)// slightly off the slot itself. Exact no of points required for the cropNode to line up correctly. Changed to y: 40 so they crop correctly and come out of the correct CG Point.
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")// this is to hide the penguin
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -120)// we position the character off screen so it appears as if its not there. put at -120 because penguins were still showing up when they should be hidden
        charNode.name = "character"
        cropNode.addChild(charNode)
        //has node and crop node that has character. We're building a tree of nodes.
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {// need to create popUpTime
        if isVisible {
            return }// we don't want the character to be shown again and again if its visible.
        
        charNode.xScale = 1
        charNode.yScale = 1
        //shows charNode at regular size.
        
        
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))// allows the charNode to move up. by y 80 degrees at 0.05 speed, v.fast.
        emerge(char: charNode)// comes out very fast and just a little below the charNode
        isVisible = true
        isHit = false //hasn't been hit by the player yet.
        
        
        if Int.random(in: 0...2) == 0 { //2/3 times good penguin other 1/3 is bad one.
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")//minor note these should be exactly the same name as they are in the assets folder.
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
            self?.hide()// the deadline calculation allows the penguins to hide after a certain amount of time hideTime * 3.5
            
        }
    }
    
    func hide() {
        if !isVisible  { return } //be careful needed return here and set is visible to false after charNode is run.
            charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
            isVisible = false
        // when penguin is hit, it will now move off screen.
    }
    
    func hit() {
        let delay = SKAction.wait(forDuration: 0.25)
        //let hit = smokeHit()
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [weak self] in self?.isVisible = false }
        smokeHit(char: charNode)
        
        let sequence = SKAction.sequence([delay, hide, notVisible]) //Cannot convert value of type 'Bool' to expected element type 'Array<SKAction>.ArrayLiteralElement' (aka 'SKAction') because it should be notVisible
        
        charNode.run(sequence)
        // we can run the sequence in this order now.
        //need to create touchesBegan method to find where it was tapped when and get a list of the nodes selected.
    }
    
    func smokeHit(char: SKSpriteNode){
        //if let particles =
        if let smokeParticles = SKEmitterNode(fileNamed: "smoke.sks") {
        smokeParticles.particleScale = 0.2;
        //smokeParticles.particleScaleRange = 0.2;
        //smokeParticles.particleScaleSpeed = -0.1
        smokeParticles.particleLifetime = 0.05
            smokeParticles.particleSpeed = 0.2
        smokeParticles.position = charNode.position //this might allow it to work
        //return SKEmitterNode(fileNamed: "MyParticle.sks")
        addChild(smokeParticles)
        }
    }
    func emerge(char: SKSpriteNode) {
        if let mudParticles = SKEmitterNode(fileNamed: "emerge.sks") {
            mudParticles.particleScale = 0.2
           // magicParticles.particleScaleRange = 0.2
            mudParticles.particleColor = .brown
            mudParticles.particleSpeed = 0.5
            mudParticles.particleLifetime = 0.07
            
            mudParticles.position = charNode.position// needed this for the 3rd challenge to get the particles to show up
            addChild(mudParticles)
        }
}
}
