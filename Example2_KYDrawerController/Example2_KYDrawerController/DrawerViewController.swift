//
//  DrawerViewController.swift
//  Example2_KYDrawerController
//
//  Created by Mallikarjun on 18/06/20.
//  Copyright © 2020 Mallikarjun. All rights reserved.
//

import UIKit
import KYDrawerController

class DrawerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let closeButton    = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: UIControl.State())
        closeButton.addTarget(self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
       )
        closeButton.sizeToFit()
        closeButton.setTitleColor(UIColor.blue, for: UIControl.State())
        view.addSubview(closeButton)
        view.addConstraint(
            NSLayoutConstraint(
                item: closeButton,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: closeButton,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
        )
        view.backgroundColor = UIColor.white
    }
    
    @objc func didTapCloseButton(_ sender: UIButton) {
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
        }
    }

}
