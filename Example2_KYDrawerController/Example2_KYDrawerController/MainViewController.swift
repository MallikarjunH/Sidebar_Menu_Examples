//
//  MainViewController.swift
//  Example2_KYDrawerController
//
//  Created by Mallikarjun on 18/06/20.
//  Copyright © 2020 Mallikarjun. All rights reserved.
//

import UIKit
import KYDrawerController

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        title = "MainViewController"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Open",
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(didTapOpenButton)
        )
    }

    @objc func didTapOpenButton(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
}
