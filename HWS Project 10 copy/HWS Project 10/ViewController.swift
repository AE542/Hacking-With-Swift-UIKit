//
//  ViewController.swift
//  HWS Project 10
//
//  Created by Mohammed Qureshi on 2020/09/09.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//UIIPCD tells us when a user has chosen an image or cancels the picker. UINCD tells us whether the user is going backwards or forwards inside the picker.
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
            //create button to add people into the app usual LBBI.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addFromCamera))
        //same method for Codable
        let defaults = UserDefaults.standard// access user defaults this way
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {//use object(forKey:) to pull out people key from save data then optional typecast (as?) data
            let jsonDecoder = JSONDecoder()
            
            do {
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            } catch  {
                print("Failed to load people")
            }
            
            //if let decodedPeople = try?// then decode it
//                NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {// then put into people array
//                people = decodedPeople// save method reverse to
                //Codable protocol works both on classes and structs. So could use that instead. Esp if app doesn't require objc compatability make a struct.
                //when implementing NSCoding, we needed to implement coding and decoding ourselves. with codable its much easier.
                //can use JSON with codable. Define struct from codable and create struct with JSON.
        }
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
           
        }
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue Person Cell.")
        }
            let person = people[indexPath.item]// need item because this code has no concept of rows its a grid.
            cell.name.text = person.name// assign this persons name to the text of our label.
            let path = getDocumentsDirectory().appendingPathComponent(person.image)
            cell.imageView.image = UIImage(contentsOfFile: path.path)// path.path converts URL to string here so it can be used.
            cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor// this allows us to get a grey colour for our bodder here by using
            cell.imageView.layer.borderWidth = 2
            cell.imageView.layer.cornerRadius = 3 //rounds the corners
            cell.layer.cornerRadius = 7 //rounds the whole cells corners to match the imageview.
            return cell//make sure this isn't in the body above.
    }
    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self //sets picker as delegate for picker
        
        //could add picker.sourceType = .camera here?
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print(true)
        } else{
            print(false)
        }
        present(picker, animated: true)//then show animation for it
    
    }
    @objc func addFromCamera() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self //sets picker as delegate for picker
        picker.sourceType = .camera
        present(picker, animated: true)//then show animation for it
        //Ok this worked for the challenge to add camera functionality. Adding a seperate objc func and navigationBarItem to handle the camera put it all together. Probably super messy code but its ok. At least you learnt how to do it.
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        //attempt to find edited image in the dictionary its passed in and typecast to UI image else invalid, just bailout.
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        //goal of this line is to read the documents directory wherever it is. When it has the directory it will append the image name to it.
        
        //now convert image to jpeg data
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)//this throws but don't need to add do and catch as it is unlikely to fail here
        }
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        //this creates a problem in that it still shows the original labels with no names because we hard coded it with number of items in section above.
        dismiss(animated: true)//dismiss the topmost VC (imagepicker) users can now pick an image an save it to the disk.
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //asks for documentDirector and then userDomainMask returns an array with the users info.
        return paths[0]
       
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
  
        if person.name == "Unknown" {
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.save()// error Value of optional type 'ViewController?' must be unwrapped to refer to member 'save' of wrapped base type 'ViewController'had to unwrap with ?
            
            self?.collectionView.reloadData()
            })// be careful with closing parens again.
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
          
        } else {
         let ac2 = UIAlertController(title: "Rename Again", message: nil, preferredStyle: .alert)
            ac2.addTextField()
            
            ac2.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac2] _ in
            guard let reName = ac2?.textFields?[0].text else { return }
            person.name = reName
                self?.collectionView.reloadData()
            })
                 ac2.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                    //self?.people.removeAll(keepingCapacity: true)
                    self?.people.remove(at: indexPath.item)
                    self?.collectionView.reloadData()
                     })
            present(ac2, animated: true)
        //SOLUTION: Extremely difficult. had to add an if and else statement here to handle two view controllers. Figured out it was if person.name == "Unknown" and else if it was a different name to get the second ac to show up. Really really hard need to look over alert controllers and closures again.
            //ac.addAction solution did the same thing below but it needed to be a seperate alert controller for the challenge.
          
          }
        
}
    
    func save() {
    
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(people) {// can't use type JSONEncoder has to be let statement jsonEncoder.
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        } else {
            print("Failed to save people")
        }
        
        
        //regular method with NSCoding
//        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
//            let defaults = UserDefaults.standard// access
//            defaults.set(savedData, forKey: "String")
        //}
    }
    
}

