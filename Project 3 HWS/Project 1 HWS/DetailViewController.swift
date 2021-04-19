//
//  DetailViewController.swift
//  Project 1 HWS
//
//  Created by Mohammed Qureshi on 2020/07/13.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController{
    @IBOutlet var imageView: UIImageView!//@IBOUtlet tells Xcode that the code and Interface Builder are connected.// UIImageView! = UIImageView may be there or it may be not but it definitely will be there by the time we use it.
    
    var selectedImage: String?//optional string (?) creating an empty one so we can connect it to our image later. This connected to the ViewController vc.selectedImage = [indexPath.Row]
    
    var selectedPictureNumber = 0
        // [Using a closed range (array [1...10]) didn't work. [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] as an array also didn't work. 1...10 also nope. [IndexPath.init(row: 1, section: 1)] DW
    
    var count = 0
    
    
    //ANSWER: Had to put vc.selectedPictureNumber = indexPath.row + 1 in override func in ViewController. This adds one 1 to the first row and counts from there.
    //Then below that had to put vc.totalPictures = pictures.count This counts all the pictures in the array and gives you 1 of 10. Was also found in Apple Documentation as a method.

    
    
    
    
    
    var totalPictures = 0//This got total pictures showing as (...of 10) however not correct.
     
   // selectedPictureNumber = pictures[indexPath.row] didn't work use of unresolved identifiers (pictures)
   // var indexPath.row = selectedPictureNumber (Int:) -> (Int) DW

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedImage//We don't need to UNWRAP selectedImage here becuase both this and title are optional strings. We're assigning one optional string to another. title is optional because its NIL by default: view controllers have no title so no text shows in the navigation bar.
        
        title = "Picture \(selectedPictureNumber) of \(totalPictures)"// using String Interpolation it shows the title in the image screen as above.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        //this shows a right bar button as shown in the code above in the navigation bar when the view controller is visible. The three params; system item we specify as .action but you can use auto code complete and give other options (remember from learning about structs). .action item displays an arrow coming out of the box, telling the user it can do something when it's tapped. .action is saying when tapped call (shareTapped).
        //#selector tells the Swift compiler that a method called shareTapped will exist and should be triggered when the button is tapped.
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .never// This makes "Storm Viewer" appear big but the detail screen looks normal.
        
        if let imageToLoad = selectedImage {// first line checkes and unwraps the optional selectedImage. if let also checks if selectedImage has a value and if so pull it out for usage otherwise do nothing.
            imageView.image =
                UIImage(named: imageToLoad)
            
            assert(selectedImage == selectedImage, "Image has no value")
            // this seemed to work for challenge 2 of Project 18. Nothing happened when the assert button was pressed.
        }
        
        // Do any additional setup after loading the view
    
        
        
    }
    override func viewWillAppear(_ animated: Bool) {//using override for each of these methods because they already have defaults defined in UIViewController and we're asking it to use ours instead. Xcode tells you when you need to use it.
        super.viewWillAppear(animated)// super.viewWillAppear/super.viewWillDisappear() = tell my parent data type that these methods were called. Here it passes to the UIViewController
        
        navigationController?.hidesBarsOnTap = true//navigationController property works fine because we pushed the navigation controller stack from View Controller. We use ? so if somehow we weren't inside a navigation view controller the hidesBarOnTap lines will do nothing.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    @objc func shareTapped() {
    guard let image =
        imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No Image Found")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image, selectedImage as Any], applicationActivities: [])
        //Challenge 1 adding as any to image, selected image solved the problem and allowed the name of the image to be displayed in the vc.
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
        
    
    //override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //if let vc = storyboard?.instantiateInitialViewController(withIdentifier: "Detail" as? DetailViewController {
            //vc.selectedImage =
                //pictures[indexPath.row]
            //navigationController?.pushViewController(vc, animated: true)
    // this is the method to

        

}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func drawOverlayText() {
        //we can use NSAttributedString here from the previous projects
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
        let paragraphStyle = NSMutableParagraphStyle() //An object for changing the values of the subattributes in a paragraph style attribute
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20), //needed seperator a comma ,
                .paragraphStyle: paragraphStyle
            ]
            
            let string = "From Storm Viewer"
            //now need to combine into an attributed string we can draw into the ctx.
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
        
        }
        imageView.image = image

}
}
