//
//  ViewController.swift
//  Project 25 HWS P2P
//
//  Created by Mohammed Qureshi on 2021/01/07.
//

//Rundown;
//We deleted the original vc in storybaords and added a collectionView vc. Embed in a navVC, set re-use ids and make sure the class is set to ViewController in the identity inspector.
//Then in the attributes inspector we changed the collection view's section insets to 10 for top, left, bottom and right. Added a UIImage view to the collection view cell. Then set the image views tag in the attributes inspector to 1000. After that select the collection view go to editor, resolve autolayout issues and reset to suggested constraints.

import MultipeerConnectivity //can be below UIKit but for the sake of alphabetical order, better to put it above.
import UIKit


class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
    }
    // need these two delegates here
    
//needs to inherit from UICollectionVC as we'll be using it in the same way we did for Project 16 with the camera app.
    var images = [UIImage]() //handles images as an array remember to init with parens.
    
    //now add MC Sessions, must be optionals
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    //depending on what user selects we need to call either startHosting and joinSession
   //var mcAdvertiserAssistant: MCNearbyServiceAdvertiser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Selfie Share"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        //need to go into info.plist and get the allow camera authentication alert to come up for the user
    
        peerID = MCPeerID(displayName: UIDevice.current.name)//get the name of the current device being used. Now needs to go inside MCSession
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required) //Value of optional type 'MCPeerID?' must be unwrapped to a value of type 'MCPeerID' error but as we JUST made the peerID value before, we can force unwrap. Because the ID exists just above this line of code.
        //Even better solution is to just assign the mcSession to the global var peerID declared above
        mcSession?.delegate = self //cannot assign value of vc to mcsession because we haven't conformed to the VC.
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }//just like a tableView, we need to call back the noOfItemsInSection to populate the tableview.
    //we can dequeue cells with the identifier 'imageview' and find the property inside them w/out a property
    //tag 1000 reason all UIView subclasses have a method called view with tag. Which searches for views inside it with the tag number. Use if let to make sure its unwrapped. So call in the func before.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)//remember internal param names, already declared in the param above.
        if let imageView = cell.viewWithTag(1000) as? UIImageView { //just like with the reuseid, here we can set the viewWithTag here. Use if let and typecast as a UIImageView. Set in the storyboard
            imageView.image = images[indexPath.item]
            //.item is the value of the item element of the index path.
        }
        return cell
    }


    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }// same method as in the camera app
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        //QUICK REMINDER OF IF AND GUARD LET from HWS: So, use if let if you just want to unwrap some optionals, but prefer guard let if you’re specifically checking that conditions are correct before continuing.
        images.insert(image, at: 0) //insert the image in the array and show it in the collectionView.
        collectionView.reloadData()
        
        //PROBLEM: Setting the constraints by resolving autolayout issues caused the image to be HUGE and then tiny when trying to resolve. Solved by changing the estimate size of automatic to none in the size inspector in storyboards.
        
        //now to send the image data using the code below.
        //1. check if peers to send to, 2. convert image to a data object from imagepicker, 3. send it to all peers, 4. show an error message if there's an issue.
        
        
        guard let mcSession = mcSession else { return }
        
        if mcSession.connectedPeers.count > 0 {// if at least 1 peer then the code runs
            //convert to png
            if let imageData = image.pngData() {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)//.reliable guarantees a delivery of a message.
                    //mcSession.connectedPeers is an array of peerIDs
                } catch  {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                    //catches errors in and sends the user a localizedDescription in the user's own language
                }
            }
        }
    }
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        //need to add new classes to handle each of these. 4 MC Sessions is required
        //all multi-peer services on iOS must declare a service type. Requires a 15 digit string that uniquely id's your service. Usually have to include your company in there.
        //this service is used by MCadvertiserAssistant and MCBrowserVC to make sure users can only see users of the same app. Both need a reference to the MCSession to handle connections.
    }
    
    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        //Cannot convert value of type 'MCSession.Type' to expected argument type 'MCSession' because it should be name of the variable mcSession not MCSession.
        //MCSession is an optional so needs to be unwrapped with guard let. //remember checking if conditions are ok before running
    mcAdvertiserAssistant?.start() //begins looking for connections
        
//        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "hws-project-25")
//        mcAdvertiserAssistant?.delegate = self; mcAdvertiserAssistant?.startAdvertisingPeer()
    }
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
        //WOULDN'T RUN ON iPHONE BECAUSE YOU DIDN'T PRESENT THE BROWSER!!!! CAREFUL!
    }
    
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    //we need these 3 session functions to conform to the MCSessionDelegate don't need any code inside them.
    
    //both methods below we need to implement need to dismiss the view controller for the multi peer browser.
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
//    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
//        <#code#>
//    }
    
    //now need to create a method to handle diagnostics. So we need to create the session func below to print out the diagnostics. Helpful for debugging.
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default: //remember @unknown is when there might be enums with possible future cases that we don't recognise at this point so we can basically future proof this default case. If the case is not one of the three above this default will trigger.
            print("Unknown state received: \(peerID.displayName)")
        }
    }
    
    //one more method to be fully compliant with the protocols. We need to add code to didFinishPickingMedia with info method so that when an image is added its sent out to our peers. In project 10 we used the JPEGData method to convert an image as a data object. We'll be using png data to send data reliably to peers. SessionDidReceive from Peer will get called with the data and we can then create a UIImage from it and save it to the images array.
    //however when you receive data, it might not be on the main thread so we need to use GCD to push the data back to the main thread.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                //if sucessful, insert into images array.
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
                //reload collectionView just like with the tableview.
                
                //now make the code to send the image data to peers; in imagePickerController func above
              
            }
        }
    }
}

