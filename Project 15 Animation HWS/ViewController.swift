//
//  ViewController.swift
//  Project 15 Animation HWS
//
//  Created by Mohammed Qureshi on 2020/11/03.
//

//When creating the Tap button above you can drag the button in the view controller scene to the view and set constraints to the bottom safe area by ctrl dragging from the button to the view.

import UIKit

class ViewController: UIViewController {
    var imageView: UIImageView! //implicitly unwrapped optional again
    var currentAnimation = 0 // to handle the counter
    
    override func viewDidLoad() {
        super.viewDidLoad()
       imageView = UIImageView(image: UIImage(named: "penguin"))
       imageView.center = CGPoint(x: 512, y: 384) //ipad center point
       view.addSubview(imageView) //adds penguin to parent (view)
    }

    @IBAction func tapped(_ sender: UIButton) {
        //every time user taps a button it will execute the animation by cycling through a counter and animating the image view.
        sender.isHidden = true //hides animation from view button is tapped.
        
       // UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {// allows the image to shake when it moves.
            switch self.currentAnimation {
            case 0:
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)// this allows the imageview to be twice its normal size.
                break
                
            case 1:
                self.imageView.transform = .identity // this resets the image back to its default state.
                break
                
            case 2:
                self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)// 256 points to the left and up //
                //can also rotate using CGAffine, using rotation angle initialiser. Accepts one param which is amount of radians it can take. Must be in CGFloat, Core Animation always takes the shortest route to make it work. E.g. if obj is straight to rotate 90 degrees it will move clockwise, half of pi. If you try to rotate pi x 2 (360 degrees), CA will calculate it as rotation with no movement.
            case 3:
                self.imageView.transform = .identity
            case 4:
                self.imageView.transform = CGAffineTransform(rotationAngle: .pi)// rotates 180 degrees.
            case 5:
                self.imageView.transform = .identity
            case 6:
                self.imageView.alpha = 0.1
                self.imageView.backgroundColor = .green
            case 7:
                self.imageView.alpha = 1.0
                self.imageView.backgroundColor = .clear
                // can even change the background colours and alpha values.
                
            default:
                break
            }
        }) { finished in
            sender.isHidden = false
        }
        
        
        
// animation block, duration 1 second, no delay,options [] = no special options, animations provided as a closure, because UIKit needs to do prep before animation starts, when ready it will call the closure with animation transformations inside.
        
        //animation closure and completion closure here. No capture list eg self, no chance of strong ref cycle. Won't hold self strongly.
        
        
        //CGAffineTransform has funcs to animate the image. All funcs return this CGAffineTransform value.
        currentAnimation += 1
        
        if currentAnimation > 7 {
            currentAnimation = 0 // this allows it to loop
        }
    }
    
}

