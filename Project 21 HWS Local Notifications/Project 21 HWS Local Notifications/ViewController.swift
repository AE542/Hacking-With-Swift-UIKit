//
//  ViewController.swift
//  Project 21 HWS Local Notifications
//
//  Created by Mohammed Qureshi on 2020/12/16.
//
//This project was to learn about how to send local notifications from an app to the user's lock screen.
//Add this to the Proto app to show which kanji's view count you've seen?

//need to enable local notifications and request permission to send info. This project needs an alert, sound, and badge. Also needs a closure to handle if they've accepted or rejected your request, also an optional to handle any potential errors.

import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        //simple mistakes, put these in viewDidLoad and not outside of it.
    }
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound])
        { granted, error in
            if granted {
                print("YEAH THAT MAKES SENSE")
            } else {
                print("Nope")
            }
        
        }
    }

    @objc func scheduleLocal() {
        
        registerCategories() //error "func called before declaration" because not in its own closure.
        //best place to call method here. iOS knows immediately what alarm means here.
        
        let center = UNUserNotificationCenter.current() // get access to the current version of our UNUserNotificaitonCenter.
        center.removeAllPendingNotificationRequests() //unschedules all pending notification requests on secondary thread
        //cancel pending notifications whose trigger hasn't been met yet.
        let content = UNMutableNotificationContent() //add arguments after the type to construct the type = put parens after to initialise the value
        content.title = "Late wake up Call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese"
        content.categoryIdentifier = "alarm" //expression has unused property error just initialise with "alarm"
        content.userInfo = ["customData": "Something"]
        //this is the way to get information to show on the local notifications.
        content.sound = .default //default notification sound.
        
        //make a calendar notification
        
        var dateComponents = DateComponents() //date or time set in minutes, hours, days etc to be used in the calendar system and time zone.
        dateComponents.hour = 10
        dateComponents.minute = 30
        
        
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        //need to make a request which ties the content and the trigger together. Has an identifier which is a string.
        //need to create unique identifier to handle this.
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // we can make the app wait 5 seconds before showing it. Better than using a calendar trigger as we can just get it to show once when we load up the app.3
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //remember UUID().string allows us to create a 'universally unique value' that can be used to identify types, interfaces and other items.
        center.add(request)// now we add it to the center var (UNUserNotificationCenter.current())
        
        //now need to make a buttons "Show me more" to launch the app from the notification.
        //UNNotificationAction launches the button
        //UNNotificationCategory groups buttons together.
        //creating a notification param is
        //need an identifier (String)
        //title which the user sees in the interface
        //options (any special options required)
        func registerLocal() {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error  in
                if granted {
                    print("Granted")
                } else {
                    print("Not Granted")
                }
            }
        }
        }
    func registerCategories() { //can call this method whenever you want.
        let center = UNUserNotificationCenter.current()
        center.delegate = self //cannot conform to vc needs a UNUserNotificationCenterDelegate above.
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more", options: .foreground)//needs to be wrapped in a notification category
        //so when we press View on the notification it comes up with a button that says tell me more which then launches the app.
        
        let reminder = UNNotificationAction(identifier: "reminder", title: "Remind Me Later", options: .foreground)
        let reminderTime = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: true)
        //86400 seconds is equal to one week.
       // this seems to be the first part of challenge 2...now how to call scheduleLocal()...
        //let schedule: () = scheduleLocal()
        
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, reminder], intentIdentifiers: [])
        //need to register with notification center
        //intentIdentitifiers: can talk to siri etc
        //options: [] is an empty array by default so we can delete it.
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
       
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            //we can read the customData key inside our userinfo dictionary as a string passed above.
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                //user swiped to unlock.
            //print("Default identifier")
                let ac1 = UIAlertController(title: "Default", message: "This is a default message", preferredStyle: .alert)
                ac1.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac1, animated: true, completion: completionHandler)
            case "show":
                //print("Show more information")
                let ac2 = UIAlertController(title: "Show", message: "Show details", preferredStyle: .alert)
                ac2.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac2, animated: true, completion: completionHandler)
            case "reminder":
                let ac3 = UIAlertController(title: "Reminder", message: "Reminder message", preferredStyle: .alert)
                ac3.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac3, animated: true, completion: completionHandler)
            default:
                break
            }
                    
        }
        
        completionHandler()
        //regardless of whether we can read custom data or not we have to call this func.
        //marked as escaping in the func, we might do some extra work here like a network request or show an alert etc, then stash it away in a property to use later on and call it when needed. Has to be called to tell iOS its completed.
    }
}

