//
//  ViewController.swift
//  Project 4 HWS
//
//  Created by Mohammed Qureshi on 2020/07/28.
//  Copyright © 2020 Experiment1. All rights reserved.
//
import WebKit //allows us to add Webkit framework

import UIKit

//enum barButtons: UIBarButtonItem {
//    case 1:
//
//    case backArrow
//}

class ViewController: UIViewController, WKNavigationDelegate {// Child classes usually inherit from their parent but here its like we're saying that class A implements from UIVC and WKND = create a new subclass of UIVC called View controller and tell the compiler we promise we're safe to use as a WKND.
    var webView: WKWebView!
    
    //UIViewController was changed to UITable View Controller. Change back if ERROR
    var progressView: UIProgressView! //view controller has no initialisers error add ! = implicitly unwrapped.
    //USE OF UNRESOLVED IDENTIFIER ERROR AGAIN BECAUSE YOU WROTE var progress: NOT varprogressView:! BE CAREFUL.
    var websites = ["apple.com", "hackingwithswift.com"]//refactoring method 1. put the websites into an array. We can now modify the initial web page so that it's not hard coded.
    
    let forwardArrow = UIImage(systemName: "arrowshape.turn.up.right.fill")
    let backwardArrow = UIImage(systemName: "arrowshape.turn.up.left.fill")
    //OK! SFSymbols button's loaded! DON'T FORGET DO NOT JUST PASTE THE IMAGE actually write the name of the SF Symbol here for this to work.
    
    
    override func loadView() {// using override func as there's already a default implementation that is to load the layout to the storyboard. We're overriding the parent class here so we need to add override to the func. Otherwise we cannot modify this function.
        webView = WKWebView()// create new INSTANCE of WKWebview then assign to the Webview property below.
        webView.navigationDelegate = self// error couldn't run as needed WKNavigationDeleget in the class. Swift suggested auto fix and added it above.
        
        //by setting the navigationDelegate property to self. This means whenever any WEB NAVIGATION happens tell me (the current view controller)
        
        //However there are 2 things you MUST DO 1: conform to the protocol = if you're telling me you can handle being my delegate, here are the METHODS you need to implement. for navigationDelegate all the methods are optional so we don't need to implement any. 2. any methods that do get implemented will now be given CONTROL over the WKWebView's behaviour. Any you DON'T IMPLEMENT will use the default behaviour of WKWebView.
        view = webView// then we make the view like so.
    }
    
    override func viewDidLoad() {

        
        super.viewDidLoad()

            
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        //again be careful where you placed the code it must flow correctly. in viewDidLoad means inside the super class of viewDidLoad not before.
        //THIS SHOULD HAVE BEEN AT THE TOP HERE NOT BELOW THE let url()
        
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //flexible space as the name suggests creates space between buttons.
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        //let forward = UIBarButtonItem(barButtonSystemItem: .rewind, target: webView, action:#selector(webView.goBack))
        //let back = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webView, action: #selector(webView.reload))
        
        let moveForward = UIBarButtonItem(image: forwardArrow, style: .plain, target: webView, action: #selector(webView.goForward))
        
        let moveBack = UIBarButtonItem(image: backwardArrow, style: .plain, target: webView, action: #selector(webView.goBack))
        //SF Symbol buttons now work!
        
        //let moveForward1 = UIBarButtonItem(barButtonSystemItem: .some(forwardArrow), target: webView, action: <#T##Selector?#>
        
        //let back = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webView, action: #selector (webView.goForward))
        //solution to challenge 2 you did yourself! adding these constants to the toolBarItems array but only using the .action as no other buttons to use...
        progressView = UIProgressView(progressViewStyle: .default)//This creates an instance of a UIProgressView and gives it a default style.
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)// this line creates a UI Progress view that is wrapped in a UIBarButtonItem
        // the progress button item has been created and it will go anywhere we want and the existing spacer will ensure it seperates from the other buttons.
        toolbarItems = [progressButton, spacer, refresh, moveBack,moveForward]// array containing flexible space and refresh button
        // we added the progressButton to the toolbarItems array also so it allows the progress bar to appear.
              navigationController?.isToolbarHidden = false //this will show the navigation controller with optional that lets the toolbar be shown because isToolbarHidden has been set to false.
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)// the addObserver method takes 4 params. who the observer is (self), what property we want to observe (estimatedProgress property of the WKWebView), which value we want (.new), and the context (nil)
        //#keyPath works like the #selector keyword it allows the compiler to check your code is correct (that the WKWebView class actually has an estimatedProgress property.
        //context: if you provide a unique value that same context value gets sent back to you when you get your notification that the value has changed.
    
        
// be careful where you place your constants here.
        let url = URL(string:"https://" + websites[0])!// creating a URL Data type is necessary and adds extra functionality this way DO NOT FORGET https:// as iOS doesn't like sending data insecurely. Can be done however. Force unwrapped with ! we know its safe to unwrap this as we know the value exists.
        
        //refactoring 2: change URL string: from https://www.google.com to + websites [0] array
        
        webView.load(URLRequest(url: url))// this line creates a new URLRequest obj from the URL and gives it to the webView to load =(webView.load) WKWebView loads the URL request not the URL directly itself.
        webView.allowsBackForwardNavigationGestures = true
    // Error consecutive statements must be seperated by line just entering down one fixes that small error.
        
        // the third line enables the property. on the web view that allows swipe gestures back and forward.
    
        //guard let selectedSite = selectedSite else {return }
        //let urlRequest = URLRequest(url: url)
        //webView.load(urlRequest)

        
    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)// we use nil for the message because the alert doesn't need a message. preferredStyle: is used for the action sheet because we're prompting the user for information.
        //in the app it showed Open page... as the title for the AC. message nil so nothing else to show.
       
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
            
        }// refactor method 3: replace the addition alert controllers addactions with for loop including addaction ac controller.
        
        // ac.addAction(UIAlertAction(title: "Google.com", style: .default, handler: openPage)) //handler is @objc func below. Note the order in which things are laid out here.
        
        //ac.addAction(UIAlertAction(title: "Twitter.com", style: .default, handler: openPage))// unresolved identifier because we haven't written open page func yet.
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))// cancel button doesn't have a handler param, so it will just dismiss the alert controller if it's tapped.
        
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
        //remember popoverPresentation Controller?.barButtonItem property is only used on iPad, and tells iOS where it should anchor the .action sheet.
        
        
    }// be careful where you place your code. It only started working when it flows downwards. One method after the other still inside the super.viewDidLoad() method.
    
    func openPage(action: UIAlertAction){
        guard let actionTitle = action.title else { return
        }
        guard let url = URL(string: "https://" + actionTitle) else { return }// we need to unwrap this string to allow it to run. hence title needed a ! after it. We know the finished string will be a valid URL. Before it was action.title!)! double force unwrapped. To be safer and make sure the url is called properly we can use guard lets with else and return to ensure the program doesn't crash.
        webView.load(URLRequest(url: url))
    }
    //if url = URL(string: !"https//" + actionTitle)
    //{ this didn't work either for challenge 1
    
   // }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }// this method updates the vc's title property to be the title of the web view, which automatically set
    //to the page title of the web page that was most recently loaded.
    
    override func observeValue (forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress =
                Float(webView.estimatedProgress)
        }// this is telling us which key path was changed, and it also sends us back the context we registered earlier so you can check whether the callback is for you or not.
        //allowed the progress bar to show the loading status with a blue bar.
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //WKWebview decidePolicyFor is a delegate callback that allows us to decide whether we want to allow navigation to happen oor not evey time something happens. We can check to see whether the URL is good.
        //The method now expects a response: should it load the page or not? this is where the decisionHandler param comes in. It actually holds a function. It's actually a closure that gives you the code and are expected to execute it.
        //As this decision Handler is a closure that you can call immediately or later on, Swift considers it to be an escaping closure. This is why we add @escaping after to acknowledge the closure might be used later.
        //now we need to evaluate the URL to see whetehr it's in our safe list then call the decisionHandler with a negative or positive answer.
        
        let url = navigationAction.request.url// set constant url to be equal to URL of navigation.
        if let host = url?.host {//if let syntax to unwrap the value of optional url.host.= if there's a host for this URL, pull it out. needs to be unwrapped because not all URLs have hosts.
            for website in websites {//loop through all sites in our safe list, placing the name of the websites var.
        if host.contains(website) {//contains() string method to see whether each safe website exists somewhere in the host.
            decisionHandler(.allow)// we want to allow loading here so we add it with . notation.
                  
        //}else if host.contains(){
            //let ac = UIAlertController(title: title, message: "You are not authorised to visit this website.", preferredStyle: .alert)
            //present(ac, animated: true)
            //first attempt at challenge 1 wouldn't load the website with an else condition it just loaded the alert controller.
            //second attempt was ! not bool operator and it just loaded the incorrect one.
        //}else{
            //decisionHandler(.cancel) 3rd this didn't work either it crashed the app decision handler wasn't called.
        //}else if host = url.host{ 4th not this either
            
            return
            
            
        }// if website was found after calling the decisionHandler we use the return statement."exit this method now." we want to
                if website.hasPrefix("https://"){
                       print(websites)
                }
    }
    // if no host set or we've gone through all the loop and foudn nothing we call the decision handler to cancel loading.
            let ac = UIAlertController(title: title, message: "You are not authorised to visit this website.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(ac, animated: true)
}// this was the solution to the first challenge...when trying to click on an external link it came up with you are not authorised to visit this website. As other links aren't contained in the array... very simple just add the AC above the decision handler(.cancel)
        //very simple and you need to solve things better...look at the code and find where you can put things after methods...remember where cancel was implemented on URLs that are not in the var array.
       
        
        
        decisionHandler(.cancel)// BE CAREFUL!!!!! There was an error saying that the decision handler was not called because it was in the above bracket. make sure it goes right at the end of the method, so it calls correctly.
//func webViewForward
}
    

}



//}
