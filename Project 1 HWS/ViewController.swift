//
//  ViewController.swift
//  Project 1 HWS
//
//  Created by Mohammed Qureshi on 2020/07/11.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "Storm Viewer"
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
    
            
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl"){
                self?.pictures.append(item)
                
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                
            }
            }
            
        }
        pictures.sort(by: {$0.self < $1.self})
        print(pictures)
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pictures.count
            
        }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text =
            pictures[indexPath.row]
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            //Project 18 challenge 2020-11-28 10:30:25.009485+0900 Project 1 HWS[1560:63704] [WindowScene] Failed to instantiate the default view controller for UIMainStoryboardFile 'Main' - perhaps the designated entry point is not set? because set exception breakpoint to obj c exceptions.
            
            //deleting navigation controller and re embedding detail vc into a nav controller got the main screen back but creates a nil error when unwrapping the image.
            
            vc.selectedImage = pictures[indexPath.row]//
           
            
            vc.selectedPictureNumber = indexPath.row + 1
            
            
            vc.totalPictures = pictures.count
            navigationController?.pushViewController(vc, animated: true)
    }
        
            }
            
   
       

    }
    

