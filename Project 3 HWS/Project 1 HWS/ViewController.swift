//
//  ViewController.swift
//  Project 1 HWS
//
//  Created by Mohammed Qureshi on 2020/07/11.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {// I want to create a new screen of data called ViewController. This is the white screen on the App because it has no data in it until we change it. ViewController can take as many properties as needed.
    //change UIViewController to UITableViewController adds extra functionality. This inherits from View Controller,(Class Hierarchy)
    var pictures = [String]()
   
    //writing an optional to find the positions of pictures in the array DIDN'T WORK
    
    
    //for challenge 12 lets write a var to hold count
    var picCount = [String: Int]()
    
    override func viewDidLoad() {// override keyword is needed because it means we want to change Apple's default behaviour from UIViewController
        
        super.viewDidLoad()//this means tell Apple's UIViewController to run it's own code before I run mine.
      
        title = "Storm Viewer"//title property selected in Main.Storyboard then used the attributes inspector after selecting title and set Accessory: to Disclosure Indicator.
        
        let fm = FileManager.default// declares a constant called fm and assigns it the value returned by FileManager.default
        let path = Bundle.main.resourcePath!// declares a constant called path that is set to the resource path of our app's bundle. This means tell me where I can find all those images I added to my app.
        let items = try! fm.contentsOfDirectory(atPath: path)// declares a 3rd constant called items. Set the contents of the directory at the path above. items will be an array of strings containing file names
        
        for item in items {// starts a loop that will execute once for every item we found in the app bundle.
            if item.hasPrefix("nssl"){// hasPrefix means it takes one parameter the prefix to search for and returns either true and false.
                pictures.append(item)
                picCount[item] = 0
                //this was the final part required to make the project 12 challenge 1 work... it needed to append the item with the nssl prefix for the pictures. we use the dictionary to add the item to the dictionary here and start the count at 0. Very very hard.
                
            }// signals the start of a new block of code.
            
        }
        pictures.sort(by: {$0.self < $1.self})//YES!!! This sorted the pictures array in numerical order sort by allows us to choose ascending order.
        //DO NOT FORGET THIS!! Apple documentation says you can sort by descending order using sort(by: >) = descending order.
        print(pictures)
        //count = count + 1 didn't work to add 1 to each cell.
        let defaults = UserDefaults.standard
        
        if let savedPictures = defaults.object(forKey: "pictures") as? Data, // you were missing a let statement to encode the savedData from the save() function...// tons of errors when you moved bracket from saved pictures to saved data. All that was required was a comma, between the if let and let constant.
        let savedData = defaults.object(forKey: "picNoCount") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                pictures = try jsonDecoder.decode([String].self, from: savedPictures)//Cannot convert value of type '[[String]]' to expected argument type '[String].Type' error...what to do here. This wasn't correct it wouldn't be able to load the data. Only would load just from pictures...a total mess. code was this  pictures = try jsonDecoder.decode([String].self, from: savedPictures)...
                picCount = try jsonDecoder.decode([String: Int].self, from: savedData) // savedData = try jsonDecoder.decode([String: Int].self, from: savedData) CANNOT USE savedData! should have been picCount
            } catch {
                print("Failed to load pictures")
            }
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {// override means the method has been defined already and we want to override existing behaviour with this new behaviour. (If you don't use override it will use the previously defined method and say there are no rows.
        //numberOfRowsInSection section: Int This describes the actual action: this code will be triggered when iOS wants to know how many rows are in the table view and section means table views can be split into sections. _ = the first parameter isn't passed in using a name when called externally.(Also a remanant of Obj C where the first param was usually built right into the method name. No need to write table view over and over like (tableView(tableView:someTableView so the underscore means you write tableView(someTableView) instead.
        
        return pictures.count// this means send back the no. of pictures in our array.
            
        }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{//override func tableView is same as prev override method above. cellForRowAt indexPath: IndexPath is called when you need to provide a row. The row to show is specified with the parameter indexPath which is of type IndexPath
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
            
        let picture = pictures[indexPath.row]// optional there might be a testLabel or not. textLabel? = do this only if there is an actual text label there or do nothing otherwise.
            cell.textLabel?.text = picture// creates a new constant called cell by dequeuing a recycled cell from the table. We have to give it the identifier of the cell type we want to recycle, so we enter the same name we gave Interface Builder "Picture"
        //moved from below this line tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
   
        cell.detailTextLabel?.text = "View Count: \(picCount[picture]!)"//"View Count: \(picCount)" this won't work needed to make a var picCount[String: Int] dictionary above to handle the title and subtitle of the cell.
        //creating constant let picture with pictures[indexPath.row] then celltextLabel?. text = picture (was missing 'picture'
        
        //Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value new problem it found nil in this code and crashed. We needed to add the picCount[item] = 0 to the for item in items loop above. This prevented allowed picCount to have a value when unwrapped.
        
        //for challenge 1 of Project 12 this is the first step to get the subtitle to show.
        //ok after changing the cell in the storyboard to have a subtitle in the id inspector now we can show a subtitle with a view count...it is ascending by number however.
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            //2: success! Set its selectedImage property]
      
            vc.selectedImage = pictures[indexPath.row]//
            
            //3: now push it onto the NAVIGATION VIEW CONTROLLER
            //vc.selectedPictureNumber =
           // count + 1
            //didn't work.
            
            //CHALLENGE was to SET these two PROPERTIES to tableView because vc. allows us to set these properties in the DetailViewController. Shows Picture 1 of 10 vc.selectedImage allows us to set the property from above. (if let vc)
            vc.selectedPictureNumber = indexPath.row + 1// removing the array brackets and adding + 1 allowed it to add 1 to the array
            //In Hacking with iOS it said we can use indexPath.row to set the selectedpicture number property in the detailViewController FROM THE VIEW CONTROLLER.
            //vc.selectedPictureNumber = count + 1
            
        //this gets the view count to set to 0 but how to increase it with each view...
            
            vc.totalPictures = pictures.count// this counted the number of images in the array in total. It connects to the variable (totalPictures) in DetailViewController.
            //In Hacking with iOS it said vc.selectedImage = pictures[indexPath.row] said 'you also learned how to set those properties from somewhere else like this' you just had to write this info. It was also shown in the numberOfRowsInSection as return.count
            
            
            navigationController?.pushViewController(vc, animated: true)
    }
        let picture = pictures[indexPath.row]
        picCount[picture]! += 1 //picCount += 1 Cannot convert value of type 'Int' to expected argument type '[String : Int]' error, Binary operator '+=' cannot be applied to operands of type '[String : Int]' and 'Int'
              save() //call save function here to make it save the counts.
              tableView.reloadData()
//        picCount[picture]! += 1 //picCount += 1 Cannot convert value of type 'Int' to expected argument type '[String : Int]' error, Binary operator '+=' cannot be applied to operands of type '[String : Int]' and 'Int'
//
//                     save()
//                     tableView.reloadData()
        //was missing a let constant to handle the let picture = pictures[indexPath.row] then we could allow the picCount to work. before this was between DetailViewController and vc.selectedImage = pictures[indexPath.row]....do not put code like this in random places...try to put them outside in between methods. One of the problems that was required was to put this code after didSelectRow so this needed to be after that code.
            }
            
   // override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
       func save() {
           let jsonEncoder = JSONEncoder()
           if let savedData = try?jsonEncoder.encode(picCount) {// adding picCount here to encode the pictures and then decode them above.
            let savedPictures = try?jsonEncoder.encode(pictures)// needed to add a new if let savePictures to encode the pictures as data. Doesn't need to be if let.
            //use of unresolved id savePictures...was missing the 'd'
               let defaults = UserDefaults.standard // only need one let default constant here
               defaults.set(savedData, forKey: "picNoCount")// create key for data to handle pics
                defaults.set(savedPictures, forKey: "pictures")
           } else {
               print("Failed to save picture")
           }// creating save function was simple it seems but not sure if its correct.
        //errors fixed but I see we needed to make two constants to handle the count and one to handle the pictures themselves.
       }


    }
    


