//
//  ViewController.swift
//  Project 28 HWS User Authentication
//
//  Created by Mohammed Qureshi on 2021/02/12.
//

// Use features face id -> enrolled, then when the face id window comes up go back in to features face id and select matching or non matching face to test.

import LocalAuthentication //allows access to touch id and face id
import UIKit

class ViewController: UIViewController {

    
    @IBOutlet var secret: UITextView!
    //text view should be set to hidden in the attributes inspector so it doesnt immediately show when the app is launched.
    
    var rightBarButton: UINavigationItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lock Screen", style: .plain, target: self, action: #selector(lockScreen(sender:)))
        //add lock button here to lock the screen when the text view is visible.
        navigationItem.rightBarButtonItem = nil
        //set to nil so not visible worked for challenge
        
        //rightBarButton?.customView?.isHidden = true
        //rightBarButton?.rightBarButtonItem?.customView?.isHidden = true
        title = "Nothing to see here" // so the view stays hidden.
        //We need to use keychain wrapper. It's open source code from MIT so we can use it here. AS LONG AS MIT is credited for its use. It can be a huge problem if you get it wrong because user data can be corrupted, lost or exposed.
        
        //unlock secret message method needs to show text view and load the keychain's text into it
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector:#selector(adjustForKeyboard) , name: UIResponder.keyboardWillHideNotification, object: nil)
        //same as project 19 we can use the notification center to hide the keyboard to show our view when entering text.
        notificationCenter.addObserver(self, selector:#selector(adjustForKeyboard) , name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
     //this will change the frame so the view still says visible when we enter text.
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
            //this it to handle calling the save method when closing the app or multitasking
        
    }

    @IBAction func authenticateTapped(_ sender: UIButton) {
        //unlockSecretMessage() //now we can open the secret message
        let context = LAContext() //class for local authentication context
        var error: NSError? //objc form of swift error, its a var so if there's an error it will show a value of WHAT went wrong.
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error ) { //&error allows us to pass in WHERE the value is in a ram so it can be overwritten with a new value of something goes wrong.
            //in out param is modified in a func and remains modded outside of func. As its objc we need to point to a piece of RAM that is an empty object we can fill in (a pointer) fill this area with this ram
            
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async { //have to put the work back on the main thread
                    if success {
                        self?.unlockSecretMessage()
                        
                        //self?.rightBarButton?.customView?.isHidden = false
                        self?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lock Screen", style: .plain, target: self, action: #selector(self!.lockScreen(sender:)))
                        
                    } else {
                    //error, can authenticate but won't work
                        
                        let ac = UIAlertController(title: "Authentication", message: "You could not be verified, please try again or enter your password.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        ac.addAction(UIAlertAction(title: "Enter Password", style: .default, handler: (self?.enterPassword)))
                      self?.present(ac, animated: true) //self being this View Controller.
                        
                    }
                }
                
        }
        } else {
            //no biometry, not enabled or failed authentication.
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authenticartion", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
            
            // this is a closure telling us if there's an error or not
        }
    }
    
    //this must be a closure because it takes tume and you don't want to block the main thread when its authenticating, it runs ASYNCHRONOUSLY somewhere else when using touch id.
    //face id needs to be a value in the property list
    
    
 //to allow the button to be hidden, we can move it behind the secret text view here when the secret text field is revealed. Do this by moving the button above the text view in the view controller scene.
    
    @objc func adjustForKeyboard (notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return } // any of the values above cannot be found, just bail immediately.
        
        let keyboardScreenEnd = keyboardValue.cgRectValue // size of the keyboard relative to the SCREEN
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window) //to take into account rotation of the device
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero //if hiding the keyboard, allows the secret text view to be the whole screen.
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0) // this sets the contentInset at the correct value. The bottom calculation is the view end frame.height - the safe area insets.bottom when visible.
        }
        secret.scrollIndicatorInsets = secret.contentInset //scroll view matches the size of the textview
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
        //scroll to whatever was selected.
        //this code is the same as Project 19
        //we don't want the user to see the secret info if they double tap the home button or leave the app.
        //In the app, the main screen returns to the authenticate screen so the user's info remains hidden when multitaskiing
}

    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff"
        
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? "" // this makes Keychain access to more accessable like UserDefaults.
           // secret.text = text -> we could to it this way with an if let but its better to use NCO because we're reading a string's data and we can just give an empty string as a default value.
    
    
}
//second method needs to write the text to the keychain and save it. We should ONLY use this when the text is visible otherwise it will overwrite the saved text if data is saved before the app is unlocked.
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else {
            return
        }// MUST show text before allowing save function to run, or bail using guard let.
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()//make the text view inactive
        secret.isHidden = true //hides text view
        title = "Nothing to see here"
        //now how do we let the users save or when they leave the app.
        
    }

    @objc func lockScreen(sender: UIAlertAction) {
        secret.isHidden = true
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItem?.isEnabled = false
        //ok making the navigation bar nil when the lock button is clicked makes it dissapear
    }
    func enterPassword(sender: UIAlertAction) {
        let ac = UIAlertController(title: "Enter your Password", message: nil, preferredStyle: .alert)
        ac.addTextField()// YOU FORGOT TO ADD THE TEXTFIELD! This is why it didn't show up
        let passwordEntry = UIAlertAction(title: "Enter", style: .default){
            [weak ac] action in// make a closure to handle text field. //weak reference cycle - DO SOME READING ON THIS!
            guard let password = ac?.textFields?[0].text else { return }
            //self?.submit(answer)// create submit func below to allow entry into the text field as a string.

            self.submitPassword(sender: password)
            //need to make submit password func.
    }
        ac.addAction(passwordEntry)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true) //was missing present ac animated true again 
}
    func submitPassword(sender: String) {
        let password = "31456"
        if password == password{
            unlockSecretMessage()
            
        }
        //Excellent! Now it works as intended! Challenge 2 done...but it can be refactored better.
    }
}
