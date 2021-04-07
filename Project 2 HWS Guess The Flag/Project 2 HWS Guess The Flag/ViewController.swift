//
//  ViewController.swift
//  Project 2 HWS Guess The Flag
//
//  Created by Mohammed Qureshi on 2020/07/21.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet var button1: UIButton!
    
    @IBOutlet var button2: UIButton!
    
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    
    var correctAnswer = 0
    
    var score = 0
    
    var savedScore = 0
    
    var highScore = 0
    

    var totalAskedQuestions = 0
    
    var gameOver = Bool()
    
    var animationCounter = 0
   

    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register Local", style: .plain, target: self, action: #selector(registerLocal))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]

        
        button1.layer.borderWidth = 1
        
              button1.layer.borderColor = UIColor.lightGray.cgColor
        
        button2.layer.borderWidth = 1
               button2.layer.borderColor = UIColor.lightGray.cgColor
               
        button3.layer.borderWidth = 1
               button3.layer.borderColor = UIColor.lightGray.cgColor
             
            
        
        askQuestion(action: nil)
        
        let defaults = UserDefaults.standard
        if let highScore = defaults.value(forKey: "highScore") as? Int {// changing the defaults to value and typecast it as an Int made this if let stamenent valid.
            self.highScore = highScore// cannot assign property to itself error...needed to change if let from savedScore to high score to solve error.
            print("Successfully loaded High Score")
        } else {
            print("Failed to save high score")
            
            
        }
        
    }
        
    func askQuestion(action: UIAlertAction!) {
            
    
            countries.shuffle()
            correctAnswer = Int.random(in: 0...2)
        
            button1.setImage(UIImage(named: countries[0]), for: .normal)
            button2.setImage(UIImage(named: countries[1]), for: .normal)
            button3.setImage(UIImage(named: countries[2]), for: .normal)
    
        
        title = "\(countries[correctAnswer].uppercased()) - Score: \(score)"
       totalAskedQuestions += 1
        if score > highScore {
            highScore = score
           save()
           }
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(showScore))
//
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        //these are supposed to go in SUPER VIEW DIDLOAD!! NOT IN A FUNC! CAREFUL
        //for challenge 3 first create bar button
        
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        //var title: String
        UIButton.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 2, options: [], animations: {
            
            var title: String

            if sender.tag == self.correctAnswer {
            title = "Correct"
                self.score += 1
                sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                sender.transform = .identity
        } else {
            title = "Wrong thats the flag of \(self.countries[sender.tag].uppercased())"
            self.score -= 1
            sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            sender.transform = .identity
  
            
        }
    
        
        
            if self.totalAskedQuestions == 20 {
                title = "Game Over! Your final score is \(self.score)"
                self.score = 0
                self.totalAskedQuestions = 0
            
            let finalAc = UIAlertController(title: title, message: "Nice!", preferredStyle: .alert)
                finalAc.addAction(UIAlertAction(title: "Game Over", style: .default, handler: self.askQuestion))
                self.present(finalAc, animated: true)
            }
            let ac = UIAlertController(title: title, message: "Your score is \(self.score).", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: self.askQuestion))
        
            self.present(ac, animated: true)// present() takes two params a view controller to present and whether to animate the presentation or not.
        //error message cannot convert value of type () -> () to expected argument type((UIAlertAction)) = using a method for this closure is fine but swift wants a method to accept a UIAlertAction param saying WHICH UIAlertAction was tapped.
           
        // else if totalAskedQuestions == 10 {
            let finalAc = UIAlertController(title: title, message: "Nice!", preferredStyle: .alert)
            finalAc.addAction(UIAlertAction(title: "Game Over", style: .default, handler: self.askQuestion))
            self.present(finalAc, animated: true)
    
            
        
        })
        }
        
        
//SOLUTION TO PROJECT 3 CHALLENGE 3
    @objc func showScore() {
        let ac = UIAlertController(title:"Score", message: "Your current score is \(score) your high score is \(highScore)", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Return", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
               present(ac, animated: true)
    }
    func save() {
      
            let defaults = UserDefaults.standard
        do {
            defaults.set(highScore, forKey: "highScore")
            print("Saved New High Score")
        } catch {
            print("Failed to save High Score")
        }
        

    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Done")
            } else {
                print("Nope")
            }
        }
    }
    
    @objc func scheduleLocal() {
        
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Let's Play!"
        content.body = "Can you remember all of your flags?"
        content.categoryIdentifier = "reminderAlarm"
        content.userInfo = ["customData": "This is custom data" ]
        content.sound = .default
        
        var dateComponents = DateComponents()
        //dateComponents.weekOfMonth = 1 //this would be the first week of the month
        dateComponents.hour = 10
        dateComponents.minute = 20
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)// to handle the notification showing up on the notification screen. Perhaps setting this to a time that includes all the seconds in the week we can solve the challenge that way? timeInterval: Set the repeats to true seconds in a week 604800
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //Instance member 'uuidString' cannot be used on type 'UUID'; did you mean to use a value of this type instead? remember UUID().string needs to be initialised with parens to work properly.
        center.add(request)
    
//        func registerLocal() {
//            let center = UNUserNotificationCenter.current()
//            center.requestAuthorization(options: [.alert, .badge, .sound])
//            { granted, error in
//                if granted{
//                    print("Granted")
//                } else {
//                    print("Ain't granted man")
//                }
//            }
//        }
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let show = UNNotificationAction(identifier: "Play", title: "Have a go", options: .foreground)
        
        
        let reminder = UNNotificationAction(identifier: "reminderAlarm", title: "Remind me in a week", options: .foreground)
        
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, reminder], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom Data received\(customData)")
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
            print("Default Action")
            
            case "show":
                print("It's showtime!")
                
            case "reminderAlarm":
                print("let me remind you")
            
            default:
                break
            }
        }
        
        completionHandler() //must always call the completion handler otherwise it won't trigger the UserNotificaionCenter.
    }



}


