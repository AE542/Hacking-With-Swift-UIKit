//
//  BuildingNode.swift
//  HWS Project 29 Exploding Monkeys
//
//  Created by Mohammed Qureshi on 2021/02/24.
//

//set up to set up name physics and building
//set up physics to configure the per physics att. for sprite's current texture
//set up buildings using core graphics to draw the buildings.
import UIKit
import SpriteKit


class BuildingNode: SKSpriteNode {
    var currentImage: UIImage! //now need to add a UIImage that stores the current texture of the building
    //will have a value in the future
    
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        //drawBuilding will create the buildings with CG, then fill them with one of 4 colours, fill the window images so it looks like lights are on and off, then it will be returned back to this method as a UIImage when the game is loaded
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        //make a new physics body everytime this is func called.
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue //from the enum
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size) //size being of type CGSize.
        
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            let colour: UIColor //again problems with colon use : its a type of uicolor not equal to a uicolor
            
            switch Int.random(in: 0...2) {
            case 0:
                colour = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                colour = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                colour = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            colour.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            //now set up the light on and off for the windows
            
            let lightOnColour = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColour = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            //this code if for setting the lights row and column heights and widths. from: 10 means indent by 10 points
            for row in stride(from: 10, to: Int(size.height - 10), by: 40 ) { //go up 40 points each time.
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    if Bool.random() { // so it sets the lights on and off at random positions
                        lightOnColour.setFill()
                    } else {
                        lightOffColour.setFill()
                    }
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                    //lets us draw the lights
                }
            }
            
        }
        //missing return function expected to return UIImage because you didn't return the image itself
        return image
    }
    
    func hit(at point: CGPoint) {
        //sprite kit configures things from the center and Core Graphics from the bottom left so need to do calculation here.
        let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y - (size.height / 2)))
        //abs takes any negative sign and make it a positive.
        
        let renderer = UIGraphicsImageRenderer(size: size)
            let img = renderer.image { ctx in
                currentImage.draw(at: .zero)
                
                ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64)) // adds circle for when banana hits and explode leaving a crater shape in the building
                ctx.cgContext.setBlendMode(.clear)
                ctx.cgContext.drawPath(using: .fill)
            }
        texture = SKTexture(image: img) //assign image to an SKTexture
        currentImage = img //updates when hits a collision
        configurePhysics() // redraws physics around new texture
        }
    }

