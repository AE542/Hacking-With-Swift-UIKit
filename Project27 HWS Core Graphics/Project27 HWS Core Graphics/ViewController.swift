//
//  ViewController.swift
//  Project27 HWS Core Graphics
//
//  Created by Mohammed Qureshi on 2021/01/25.
//
//

//most important thing from this lesson is to learn you x and y coordinates so you can type them out more accurately next time.

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var currentDrawType = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        drawRectangle()
    
        //now will load the first image
        //drawCircle()
    }

    @IBAction func redrawButton(_ sender: Any) {
        currentDrawType += 1
        //needed to add this so it adds 1 to the currentDrawType and then we can move through each case. REMEMBER THIS!
        if currentDrawType > 8 { // if greater than 5 reset to zero // so when pressing the redraw button it adds and appends 1 to the currentDrawType so thats why it takes 5 presses of the redraw button to change the image.
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawEmoji()
            
        case 1:
            drawCircle()
            
        case 2:
            drawCheckerboard()
            
        case 3:
            drawRotatedSquares()
            //this one is more difficult. We need to translate the current transformation matrix, how to rotate it and how to stroke the correct path for line width.
        //need to move the TM half way into the image from the top left corner where its loaded by default in CoreGraphics
        case 4:
            drawLines()
            
        case 5:
            drawImagesAndText()
            
        case 6:
            
            drawRectangle()
            
        case 7:
            drawTriangle()
            
        case 8:
            drawTwinText()
            
        default:
            //drawRectangle()
        break
        }
    }
    
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) //creates canvas for drawing using CoreGraphics.
        //currentDrawType += 1
        //CoreGraphics sits at a lower technical level than UIKit so you have to use alternatives. Have to use CGColor or use helper methods from UIKit to differentiate between the two
        //CoreGraphics differentiates between creating and drawing the path. It's like a state (creating) and performing (action) can also work on the background thread without locking the UI.
        let image = renderer.image { ctx in
            //awesome drawing code = create stroked rectangle.
            //we can add multiple paths to the ctx here ui graphics image renderer context.
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)//10pt border around rect 5pt inside and 5pt outside of rect. Will be outside of the canvas
            
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke) //fill rect and stroke around edges (border)
            // this creates a red rectangle on the screen.
            
        }
        imageView.image = image //put the rendered image into the UIImageView
    }
    
    func drawCircle() {
        //this func is mostly the same as the drawRectangle method. But we only need to change one line of code: the cgContext.addRectangle -> .addEllipse
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 15, dy: 15)
            //insets the circle by 5 points from every direction
                //CGRect(x: 5, y: 5, width: 502, height: 502)
            // changed the x and y coordinates from 0 to 5 and the width minus 10 points from 512 to 502 so the circle doesnt clip the edges its assigned to
            //alternate method is
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            
        }
        imageView.image = image
    }

    
    func drawCheckerboard() { //remember to add the func to the switch stament.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            //now need to set rows and columns to create the checkboard.
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    
                    if (row + col).isMultiple(of: 2) {
                    //if (row + col) % 2 == 0{ //% = modulus used this in your own app for getting view counts assigned to each item in the arrays. Can also use multiple of 2 to get it to show correctly
                        
                        //if there's square coloured black we can fill that space with this colour. Checkboards have black white black white and then the next row is white black white black. So this code offsets the rows and creates the checkboard effect.
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64)) //64 x 64 makes 512 so it fills the whole screen.
                        //problem where you typed (x: col * 64, y: col * 64, width: 64, height: 64) col twice so it only loaded the indivdual columns and not in a checkboard because no rows!
                        
                    }
                }
            }
            
        }
        imageView.image = image
        
    }
    func drawRotatedSquares() { //remember to add the func to the switch statement.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256) //half of 512
            let rotations = 16
            let amount = Double.pi / Double(rotations) //each rotation will rotate by pi divided by the no of rotations(16) 180 degrees 1/16th of this amount.
            
            for _ in 0 ..< rotations {
                ctx.cgContext.rotate(by: CGFloat(amount))//above calculation
                //this transformation is applied to the top of whatever was created. This allows the squares to be overlayed on top of each other.
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
                //have to go back and left (x: -128, y: -128, and center by 256 * 256) because CoreGraphics loads the default point in the top left? corner.
            }
            ctx.cgContext.setStrokeColor(UIColor.blue.cgColor)
            ctx.cgContext.strokePath()//paints a line along the current path.
            
        }
        imageView.image = image
        
    }
    func drawLines() {
        //needs to translate and rotate the CTM. Needs to be 90 degrees so it can draw boxes in side boxes in a square spiral. Need to decrease the line length so it can shrink the boxes into a spiral.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
             let width: CGFloat = 50 // creating a constant was a good idea but it doesn't need to be mutated so turn it into a let constant.
            
            for _ in 0 ..< 256 { //256 lines
                ctx.cgContext.rotate(by: .pi / 2)
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: width))//move begins a new subpath at the desginated point (length and height)
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: width))
                }
                length *= 0.99 //multiply and append each time so it decreases everytime a subpath is created to give the portal effect
            }
            ctx.cgContext.setStrokeColor(UIColor.orange.cgColor)
            ctx.cgContext.strokePath()
           
            
        }
        imageView.image = image
        
    }
    
    func drawEmoji() {
        //this func is mostly the same as the drawRectangle method. But we only need to change one line of code: the cgContext.addRectangle -> .addEllipse
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 15, dy: 15)
         
            ctx.cgContext.addEllipse(in: CGRect(x: 130, y: 180, width: 50, height: 50))
            //ctx.cgContext.setFillColor(UIColor.brown.cgColor)
//            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            //ctx.cgContext.fillEllipse(in: CGRect(x: 130, y: 180, width: 50, height: 50))
            
            ctx.cgContext.addEllipse(in: CGRect(x: 340, y: 180, width: 50, height: 50))
            //.addEllipse allows the circles to be drawn and given dimensions.
            
            ctx.cgContext.move(to: CGPoint(x: 370, y: 370))
            ctx.cgContext.addLine(to: CGPoint(x: 150, y: 400))
            //ctx.cgContext.setFillColor()
            //this gets the line to show up but it still isn't horizontal like I want it.
           // ctx.cgContext.addLines(between: [CGPoint])
            //now horizontal but too large
            //got the disappointed face emoji to show up here.
            
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
        }
            
//            let newRenderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50))
//            let detailsImage = newRenderer.image { ctx in
//                let rectangle2 = CGRect(x: 0, y: 0, width: 150, height: 150).insetBy(dx: 100, dy: 100)
//                //need to add a container like a rectangle to hold the eyes for the emoji?
//
//                ctx.cgContext.setFillColor(UIColor.brown.cgColor)
//                ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
//                ctx.cgContext.setLineWidth(10)
//                ctx.cgContext.addEllipse(in: rectangle2)
//                ctx.cgContext.drawPath(using: .fillStroke)
//
//            }
         

        //imageView.image = detailsImage
        
        imageView.image = image
    }
    
    func drawFeatures(){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50))
        let image = renderer.image { ctx in
            let rectangle2 = CGRect(x: 100, y: 100, width: 20, height: 20)
            //need to add a container like a rectangle to hold the eyes for the emoji?
            
            ctx.cgContext.setFillColor(UIColor.brown.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.addEllipse(in: rectangle2)
            ctx.cgContext.drawPath(using: .fill)
        }
        imageView.image = image
    }
    func drawImagesAndText() {
        //we can use NSAttributedString here from the previous projects
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
        let paragraphStyle = NSMutableParagraphStyle() //An object for changing the values of the subattributes in a paragraph style attribute
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36), //needed seperator a comma ,
                .paragraphStyle: paragraphStyle
            ]
            
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            //from of mice and men
            //now need to combine into an attributed string we can draw into the ctx.
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            //pulled in from the edge of the rectangle slightly CGRect(x: 32, y: 32, width: 448, height: 448)
            //.usesLineFragmentOrigin lets us use line wrapping more easily
            let mouse = UIImage(named: "mouse-1")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        imageView.image = image
        
    }
    
    func drawTriangle() {
        let renderer1 = UIGraphicsImageRenderer(size: CGSize(width: 500, height: 500))
        let image1 = renderer1.image { ctx in
            
            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
            ctx.cgContext.setLineWidth(5)
            
            ctx.cgContext.move(to: CGPoint(x: 50, y: 450))
            ctx.cgContext.addLine(to: CGPoint(x: 250, y: 50))
            ctx.cgContext.addLine(to: CGPoint(x: 450, y: 450))
            ctx.cgContext.addLine(to: CGPoint(x: 50, y: 450))
            
            let rectangle1 = CGRect(x: 0, y: 0, width: 512, height: 512)
            ctx.cgContext.addRect(rectangle1)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = image1
    
    }
    
    func drawTwinText() {
        let renderer1 = UIGraphicsImageRenderer(size: CGSize(width: 500, height: 500))
        let image1 = renderer1.image { ctx in
            //need to use move to and add line to to make the words twin.
            //ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            let offset = 50
            //if there's no offset for the x axis added, the lines aren't centered in their container.
            
            
            ctx.cgContext.move(to: CGPoint(x: 50 + offset, y: 160))
            ctx.cgContext.addLine(to: CGPoint(x: 130 + offset, y: 160))
            //slighty off center so changed x to 130 from 150
            //this draws the first line of the T
            ctx.cgContext.move(to: CGPoint(x: 90 + offset, y: 160))
            ctx.cgContext.addLine(to: CGPoint(x: 90 + offset, y: 300))
            //This draws the longer part of T
            
            
            ctx.cgContext.move(to: CGPoint(x: 136 + offset, y: 160))
            ctx.cgContext.addLine(to: CGPoint(x: 156 + offset, y: 290))
            //\
            ctx.cgContext.addLine(to: CGPoint(x: 176 + offset, y: 180))
            // -/
            ctx.cgContext.addLine(to: CGPoint(x: 196 + offset, y: 290))
            //-\
            ctx.cgContext.addLine(to: CGPoint(x: 216 + offset, y: 160))
            // -/
            
            ctx.cgContext.move(to: CGPoint(x: 236 + offset, y: 160))
            ctx.cgContext.addLine(to: CGPoint(x: 236 + offset, y: 300))
            //this worked for the I remember to increment by the move to x axis cg point by an equal space each time
            
            
            ctx.cgContext.move(to: CGPoint(x: 250 + offset, y: 300))
            //ctx.cgContext.addLine(to: CGPoint(x: 276 + offset, y: 160))
            ctx.cgContext.addLine(to: CGPoint(x: 250 + offset, y: 165))
            //|
            ctx.cgContext.addLine(to: CGPoint(x: 328 + offset, y: 295))
            //\
            ctx.cgContext.addLine(to: CGPoint(x: 328 + offset, y: 165))
            //|
            
            ctx.cgContext.move(to: CGPoint(x: 370 + offset, y: 300))
            ctx.cgContext.addLine(to: CGPoint(x: 370 + offset, y: 160))
            ctx.cgContext.addLine(to: CGPoint(x: 350 + offset, y: 180))
            //created an extra 1 to practice
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            ctx.cgContext.drawPath(using: .stroke)
            //not fillstroke, that just fills all the space between the lines
        }
        imageView.image = image1
    }
    
}

