//
//  AppDelegate.swift
//  Example1_SWRevealViewController
//
//  Created by Mallikarjun on 12/06/20.
//  Copyright © 2020 Mallikarjun. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if GlobalVariables.sharedManager.loggedIn {
            
            //navigate to Home ViewController
            
            //naviagate to Inbox VC
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let inboxVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            
            let navigation: SampleNavigation = SampleNavigation(rootViewController: inboxVC)
            
            let sidemenu = mainStoryboard.instantiateViewController(withIdentifier: "SideMenuBar") as? SideMenuBar
            
            let vc = SWRevealViewController(rearViewController: sidemenu, frontViewController: navigation)
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            
        }else{
            //navigate to Login ViewController
            let loginVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController")
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = loginVC
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

