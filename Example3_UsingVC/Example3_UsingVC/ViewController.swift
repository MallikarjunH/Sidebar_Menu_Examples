//
//  ViewController.swift
//  Example3_UsingVC
//
//  Created by Mallikarjun on 14/07/20.
//  Copyright © 2020 Mallikarjun. All rights reserved.
//

import UIKit
import  SideMenu

class ViewController: UIViewController {

    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        menu = SideMenuNavigationController(rootViewController: MenuListVC())
        menu?.leftSide =  true
        
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }

    @IBAction func didTapMenu() {
        present(menu!, animated: true)
    }
}

