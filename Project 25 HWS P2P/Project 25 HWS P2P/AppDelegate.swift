//
//  AppDelegate.swift
//  Project 25 HWS P2P
//
//  Created by Mohammed Qureshi on 2021/01/07.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


var window: UIWindow?
    //to help solve the multi peer connectivity issue. Also commenting out UISceneSession Lifecycle and below's code. However still having problem with the devices being unable to connect or discover each other.
    //deleted Application from scene manifest in the Info.plist also.

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


}

