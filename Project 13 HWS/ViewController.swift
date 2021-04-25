//
//  ViewController.swift
//  Project 13 HWS
//
//  Created by Mohammed Qureshi on 2020/10/09.
//  Copyright © 2020 Experiment1. All rights reserved.
//

//For this project we created a single view app then after that we added a UI Image View changed the background to grey. Then we added a UISlider and two buttons. Changing the sizes of the frame rectangle in the size inspector was simple. We also used the Editor to resolve autolayout constraint problems. Problem with the view in landscape being too squashed. to the top. To resolve that, change the constraint of the view bottom in the size inspector to 20. Looks much better.

//View debugging from project 18 by loading up the project selecting the two rectangles. Then you can see the view in 3D and check if there are any views overlapping or causing errors.


import CoreImage// need to do hits first to access core image
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {// needed to add these so picker.delegate could conform to class.
    @IBOutlet var selectFilter: UIButton!// simply had to create an outlet to change the title of the button for challenge 2
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var intensity: UISlider!
    
    @IBOutlet var radius: UISlider!//first create slider
    
    var currentImage: UIImage! //this will store the image the user selected.
    
    var context: CIContext!// handles rendering
    var currentFilter: CIFilter! //expected name or member type error remember not to use = and use : after declaring vars and constants.
    
    //var selectFilter: UIButton!//maybe make a button this way? perhaps we need to create another button to handle this... This wasn't the solution either. We ahd to create a new IBOutlet called select filter to handle this.
    
    var currentImageNo = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "InstaFilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        context = CIContext() //not implicitly unwrapped
        currentFilter = CIFilter(name: "CISepiaTone")
//        let currentFilterSelected = currentFilter
//        if currentFilterSelected ==
    }
    
    @objc func importPicture() {// same as project 10
        let picker = UIImagePickerController()
        picker.allowsEditing = true
    
        
        picker.delegate = self// need to conform to 2 protocols to allow this to work
        
        
        present(picker, animated: true)
    }// needed to add Privacy photo library additions to the Info.plist, right click and create the property to allow access to the photo library

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true) //dismiss if there is an error using guard let
        currentImage = image// assign currentImage to this image property. Saves a copy of the image to be used when its reloaded again
        //UIImageView.animate(withDuration: 1.5, delay: 0, options: [], animations: {
        UIImageView.transition(with: imageView, duration: 0.75, options: .transitionCrossDissolve,animations: {self.imageView.alpha = 1.0} ,completion: nil)
            //stack overflow solution also worked really well.
            
//                self.imageView.alpha = 0
//
//                let fadeIn = CABasicAnimation(keyPath: "opacity")
//                fadeIn.fromValue = 0
//                fadeIn.toValue = 1
//                fadeIn.duration = 1.5
//
//                self.imageView.alpha = 0.5
//                //self.imageView.transform = .identity
//
//
//                self.imageView.alpha = 1.0
//
//        })// somehow this worked for Project 15 challenge 2. Didn't work in importPicture func but here it loads smoothly and runs through each alpha value.
        
        let beginImage = CIImage(image: currentImage);       currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()// then call inside intensityChanged method
        
    }
    
    
    @IBAction func changeFilter(_ sender: UIButton) { //we can now add change filter to a UI Button by changing the sender
       // guard let sender.currentTitle = currentFilter else { }
        //let currentTitle = changeFilter.self
        //changeFilter.self.setTitle
        //sender.currentTitle == currentFilter
        //let sender.currentTitle == currentFilter
        
        let ac = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)// requires a popover presentation controller to be used on iPad. We want to call this from a UIButton
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))// error in name 'Blur' not 'Blue' caused fatal nil was found error
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter)) //found nil when unwrapping error because CIPixellate wasn't spelt correctly. Be careful
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))// was missing before
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIDiscBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIHoleDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        //ac.addAction(UIAlertAction(title: "change", style: , handler: UIControl.State.normal))
        if let popOverController = ac.popoverPresentationController {// if let to unwrap optionals guard let to check conditions are correct.
            popOverController.sourceView = sender // use button that was tapped as the source of the sender.
            popOverController.sourceRect = sender.bounds //used alongside sourceView above and here's the view and the rectangle around it will use x and y values (0.0).
           // currentTitle = sender.currentTitle
            //changeFilter.(UIControl.sender)
            //challenge 2 attempts
//            let currentFilterSelected = currentFilter
//            if currentFilterSelected.inputKeys {
//                not quite the right answer
//            }
        }
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        //print(action.title!) just as a test the change filter button loaded up the UIAC perfectly on iPad Pro and a regular iPhone 11 on the simulator.
        selectFilter.setTitle(action.title, for: .normal)
        //SOLUTION FOR Challenge 2 CREATE AN IBOUTLET FROM THE BUTTON THEN ACCESS ITS VALUE USING SET TITLE FOR UI CONTROL STATE NORMAL... simple.
        //MUST BE BEFORE guard let to work...
        //setFilter(action: action.title, for: .normal).setTitle(action.title, for: .normal)
        guard currentImage != nil else { return } // we want to make sure an image has been selected by the user so we use a guard let again here
        guard let actionTitle = action.title else {
            return } //create a new CIFilter from the actionTitle
//        let selectFilterTitle = action.title
//        selectFilterTitle.setTitle(action.title)//Value of type 'String?' has no member 'setTitle'
        currentFilter = CIFilter(name: actionTitle)
        //selectFilter.setTitle(action.title, for: .normal)//caused fatal error and found nil
        //currentFilter.setValue(actionTitle,)
        
        let beginImage = CIImage(image: currentImage)// create new image from currentImage property
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey) //use in current filter.
        //Thread 1: Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value when selecting CIPixelate
        applyProcessing()
    }
    
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else {
            // This was the solution to Challenge 1...the vc had to be put into the guard let function as it's checking to see if the image is there... READ UP ON GUARD LET AGAIN
            let ac = UIAlertController(title: "No image selected!", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
            //next time try and put it in all the places inside the method as it was the right method just not the right place.
            
            
            return
            
        } // because we used guard let again we can delete imageView and the force unwrap ! from imageView.image! because if save when nothing to save it will crash the app. so better to use guard let.
        
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil) //now
        //if error has occured we need to unwrap image and use localised image property so it tells user the problem in their own language
        //CHALLENGE 1 ATTEMPTS
        //image = currentImage cannot assign //current image is a let constant.
//        if currentImage.imageAsset == nil{
//            let ac = UIAlertController(title: "No image selected!", message: nil, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//            //first attempt at challenge 1
//            //currentImage == nil doesn't work nothing happens when the save button is pressed.
//            // if imageView.image == nil didn't work
//            //if imageView.image.self == nil { nope
//            //if imageView.image != image { nope
//            //if currentImage.ciImage == nil
//            //if image != imageView nothing
//            //if image == nil Comparing non-optional value of type 'UIImage' to 'nil' always returns false
//            //if currentImage.images == nil
//            //if currentImage != imageView.image
//            //if currentImage == nil
//            //if currentImage.imageAsset == nil
//        }
       
        
    }
    
    
    
    @IBAction func intensityChanged(_ sender: Any) {//connected to the UISlider's value when it's changed.
        
        applyProcessing()// this will be called when the image is imported and when the slider is moved.
    }
    
    
    @IBAction func radiusChanged(_ sender: Any) {
        applyProcessing()// this worked for the challenge. Remember you had to link up an IBOutlet and IBAction to the vc then you had to change apply processing so it could use the radius value to change. Finally add applyProcessing to the IBAction func. inputKeys as filters were already set so you could just add it this way.
    }
    
    
    func applyProcessing() {
    
        let inputKeys = currentFilter.inputKeys
        
        
       // guard let outputImage = currentFilter.outputImage else { return }// basically bail out if output image is anything different that the above.
        //currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)// can't convert an image into a CIIMage easily so we need to use CG image as a bridge and gives the image a filter
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        } //if we have intensity in our input keys we can used our slider for that. This helps prevent crashes as some filters don't have intensity values.
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius.value * 150, forKey: kCIInputRadiusKey) //NSKey Unknown Exception error caused by accidentally typing this forKey: kCIIntensityKey) instead of radius key. fixed by changing to kCIInputRadius key.
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
            
    
        }// all these if statements handle the different kinds of kCIInputs and cover all the angles that are presented to allow us to manipulate the iamges.
         guard let outputImage = currentFilter.outputImage else { return }// basically bail out if output image is anything different that the above.
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {// output image is an optional so needs to be force unwrapped. //we create a cg image from our core image filter. outputImage!.extent part reads the whole image.
            //we can refactor this without all the force unwraps to make it better code as it works in theory but we want it to work in an app 100% of the time. Even if with this method it's unlikely to fail.
            //(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) before cgImage was this. by creating the guard let to handle the current filter, it allows us to get rid of the optionals.
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
            
            //there are 4 input keys we can manipulate across 7 different filters. Each filter has an inputKeys property that returns an array of the keys it supports. We can use this with an isContains method to see if it work.
        }
        
            
        }
        @objc func image (_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {// @objc can only be used with members of classes, @objc protocols, and concrete extensions of classes because was in above func accidentally
            //called from save method
//            if imageView != nil {
//                let ac = UIAlertController(title: "No image selected!", message: nil, preferredStyle: .alert)
//                          ac.addAction(UIAlertAction(title: "OK", style: .default))
//                          present(ac, animated: true)
//            }
//            if let image = error {
//                if imageView! == nil {
//                      let ac = UIAlertController(title: "No image selected!", message: nil, preferredStyle: .alert)
//                      ac.addAction(UIAlertAction(title: "OK", style: .default))
//                      present(ac, animated: true)
//                } else {
//                    print("Error")
                // this is making challenge 1 more complicated than it needs to be.
                    //if currentImage == nil doesn't work either
                    //if imageView! == nil comparing non optional val UIImage view to nil always fails. so it won't work
//            }
            if let error = error {
                let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)// localised description shows the error for specific regions.
                ac.addAction(UIAlertAction(title: "OK", style: .default))
            } else {
                let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
                //Cannot convert value of type 'String' to expected argument type 'UIAlertAction.Style' supposed to be a UIAlertController not an Alert Action.
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
            
    }
    
}

