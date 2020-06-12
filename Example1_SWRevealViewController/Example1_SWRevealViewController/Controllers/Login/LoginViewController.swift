//
//  LoginViewController.swift
//  Example1_SWRevealViewController
//
//  Created by Mallikarjun on 12/06/20.
//  Copyright © 2020 Mallikarjun. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let inboxVC = mainStoryboard.instantiateViewController(withIdentifier: "InboxViewControllerId") as! InboxViewController
        
        let navigation: SampleNavigation = SampleNavigation(rootViewController: inboxVC)
        
        let sidemenu = mainStoryboard.instantiateViewController(withIdentifier: "SideMenuBarId") as? SideMenuBar
        
        let vc = SWRevealViewController(rearViewController: sidemenu, frontViewController: navigation)
        
        self.present(vc!, animated: true)
    }
    
    
}
