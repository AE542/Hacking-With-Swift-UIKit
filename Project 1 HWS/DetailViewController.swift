//
//  DetailViewController.swift
//  Project 1 HWS
//
//  Created by Mohammed Qureshi on 2020/07/13.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    @IBOutlet var imageView: UIImageView!//@IBOUtlet tells Xcode that the code and Interface Builder are connected.// UIImageView! = UIImageView may be there or it may be not but it definitely will be there by the time we use it.
    
    var selectedImage: String?//optional string (?) creating an empty one so we can connect it to our image later. This connected to the ViewController vc.selectedImage = [indexPath.Row]
    
    
    
    var selectedPictureNumber = 0
        // [Using a closed range (array [1...10]) didn't work. [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] as an array also didn't work. 1...10 also nope. [IndexPath.init(row: 1, section: 1)] DW
    
    
    
    //ANSWER: Had to put vc.selectedPictureNumber = indexPath.row + 1 in override func in ViewController. This adds one 1 to the first row and counts from there.
    //Then below that had to put vc.totalPictures = pictures.count This counts all the pictures in the array and gives you 1 of 10. Was also found in Apple Documentation as a method.

    
    
    
    
    
    var totalPictures = 0//This got total pictures showing as (...of 10) however not correct.
     
   // selectedPictureNumber = pictures[indexPath.row] didn't work use of unresolved identifiers (pictures)
   // var indexPath.row = selectedPictureNumber (Int:) -> (Int) DW

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedImage//We don't need to UNWRAP selectedImage here becuase both this and title are optional strings. We're assigning one optional string to another. title is optional because its NIL by default: view controllers ahve no title so no text shows in the navigation bar.
        
        title = "Picture \(selectedPictureNumber) of \(totalPictures)"// using String Interpolation it shows the title in the image screen as above.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))// couldn't call shareTapped because it was in the view controller not in the DVC.
        
        //navigationItem.prompt = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButton))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .never// This makes "Storm Viewer" appear big but the detail screen looks normal.
        
        if let imageToLoad = selectedImage {// first line checkes and unwraps the optional selectedImage. if let also checks if selectedImage has a value and if so pull it out for usage otherwise do nothing.
            imageView.image =
                UIImage(named: imageToLoad)
            
            assert(selectedImage == selectedImage, "Image has no Value")
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
    
    //override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //if let vc = storyboard?.instantiateInitialViewController(withIdentifier: "Detail" as? DetailViewController {
            //vc.selectedImage =
                //pictures[indexPath.row]
            //navigationController?.pushViewController(vc, animated: true)
    // this is the method to

    
    @objc func shareTapped() {
        guard let recommend = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("Share this image!")
            return
        }
        let vc = UIActivityViewController(activityItems: [recommend], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
        
    }
    
    //@objc func shareButton() {
        //guard let image =
            //imageView.image?.jpegData(compressionQuality: 0.9) else {
        //print("Share this image")
        //return
    }
        //let items = ["Share this app with your friends!"]
    //let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        //present(vc, animated: true)
//rr}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */





//}
