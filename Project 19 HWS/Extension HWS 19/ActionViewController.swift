//
//  ActionViewController.swift
//  Extension HWS 19
//
//  Created by Mohammed Qureshi on 2020/12/03.
//

//JavaScript in Action.js file had to be absolutely perfect otherwise it wouldn't work.

import UIKit
import MobileCoreServices

//iOS acts as an intermediary between the extension and safari for security reasons.

class ActionViewController: UIViewController {


    @IBOutlet var script: UITextView!
    
    
    var pageTitle = ""
    var pageURL = ""
    //two vars being passed in from Safari. Pass them below in the itemProvider.loadItem method.

    var currentJavaScriptSample = NSExtensionItem()
    
    let url = "https://www.apple.com"
    override func viewDidLoad() {
        super.viewDidLoad()
    //deleted all the pre loaded code that used to be here.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector((done))) //target should be self not nil
            //deleted nav bar and now we can use a UIBBI here instead.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(selectSampleJavaScript))
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //allows us to capture two kinds of messages from the system with these two observers
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem
        {
            //when extension item is created extensionContext is created. inputItems is an array or items. It might not exist so we use as? to conditionally typecast
            if let itemProvider = inputItem.attachments?.first { //attachments is an array. Code will pull out the first item that was shared with us.
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
                    //asks itemProvider to provide an item. This closure will execute here because it prevents freezing of the UI while its loading up.
                    [weak self] (dict, error) in// we need weak self because we're using it inside a closure to store this property away somewhere until its needed. Don't use strong reference cycles.
                    //dict contains what actually was provided by iOS.
                    
                    //After this we went to the Extension folder's Info.plist to add some NSExtensions so we can use JavaScript
                    //NSExtensionActivationRule changed from TRUEPREDICATE (as a string, this ext works with any kind of data shared with any kind of compatible app, don't want this so changed to dictionary)
                    //add NSExtensionActivationSupportsWebPageWithMaxCount, case sensitive. Value is 1 = can only accept one value for a webpage, not images or other data types
                    //add NSExtensionJavaScriptPreprocessingFile, case sensitive. String value of Action
                    
                    guard let itemDictionary = dict as? NSDictionary else {
                        return
                    }// optionally typecast the dict as an NSDict so it doesn't cause a huge error.
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }//NSDictionary is like a dictionary but doesnt need to declare what types it holds. It just holds all the info Apple wants us to have and it goes into the itemDictionary constant. Typecasting the value of the NSExtJSPreprocessingRKey so we can use it as swift value.
                   // print(javaScriptValues) printed {
//                    URL = "https://www.apple.com/";
//                    title = Apple; ----> printed to the debug console so its working properly.
//                }
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    //set these two properties to update the UI.
                    
                    DispatchQueue.main.async { //push work back to main thread to update UI.
                        self?.title = self?.pageTitle
                        //sets two properties to values from the javaScripteValues dict typecasting it
                        //closure being run can be called on any thread so have to use GCD here.
                        //don't need [weak self] in because this outer closure has already declared a weak self. So it's captured here as a weak self.
                    }
                }
            }
        }
       
        
//        if let javaScriptString = UserDefaults.standard.value(forKey: "AlertDoc") as? String {
//            //script.text = "alert(document.title)"
//            //return urlString
//            //only loads up it up but doesn't actually save it...
//
//        }
//        return
        
        
        
    }

    @IBAction func done() {
        let item = NSExtensionItem() //initialise with parens
        let argument: NSDictionary = ["customJavaScript": script.text]
        //added string default value to stop the coercion of implicity unwrapped error but it stopped the script being loaded from the ac I created...
        //wouldn't load JS window before because string was custom not customJavaScript as it is in Action.js also careful of semi-colon usage.
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
        //Opposite of code above bundling up and send to Safari
        //passes back input items to parent app (Safari). Data returned here will be passed into the finalize func in Action.js file.
       
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        //Notification containts name and userInfo.
        //NSValue is a wrapper around structures. Above code contains CGRect value property here
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        //view.convert from converts the view window
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        //get back converted frame and the correct size for the keyboard if in landscape
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else  {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
             
            
        }
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
        //this code allows us to continue typing below the keyboard. Before we could continue typing below the keyboard but it wouldn't auto scroll up to accomodate for new lines of texts. This code solves that problem.
    }
    
    @objc func selectSampleJavaScript() {
        let ac = UIAlertController(title: "Sample Scripts", message: "Choose you script", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Alert", style: .default, handler: chooseJavaScriptSample))
        ac.addAction(UIAlertAction(title: "Return", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
        present(ac, animated: true)
        
    }
    
    func chooseJavaScriptSample(action: UIAlertAction) {//should be a UIAlert action as its being used in the func above.
//        var javaScriptSample = String()
//        javaScriptSample = "direction.title"
//        print(javaScriptSample)
        self.script.text = "alert(document.title);"

        //alertDocumentTitle = "alert(document.title);"
        
        
        //This was the solution to challenge 1. I didn't know about the script var of a UITextView! force unwrapped, it prints out a pre loaded script written here.
        //AH! the IBOutlet is a script var of UITextView so we needed to call it from here.
        //UserDefaults.standard.setValue(alertDocumentTitle, forKey: "AlertDoc")
        //somehow this is actually saving the document title so its pre loaded when I open the extension....kind of works?
//return firstJavaScriptSample
    }
    
    func saveJavaScriptInput() {
        let defaults = UserDefaults.standard
    
        
        //let url = "www.apple.com"
        //let url = URL(forKey: "www.apple.com")
        defaults.set(url, forKey: "Site")
    
        let url = defaults.url(forKey: "Site") as? String
    }

}
