//
//  SigningSiri.swift
//  emSigner
//
//  Created by Emudhra on 20/01/20.
//  Copyright © 2020 Emudhra. All rights reserved.
//

import Foundation
import UIKit
import Intents
import os.log
import IntentsUI

class SigningSiri: UIViewController{
    
    override func viewDidLoad() {

           super.viewDidLoad()
       }
          
}

extension SigningSiri{
    @objc func addSiri(){
        
        let newArticleActivity = NSUserActivity(activityType: "com.emudhra.emSigner.SignDocument")
        newArticleActivity.persistentIdentifier =
        NSUserActivityPersistentIdentifier("com.emudhra.emSigner.SignDocument")
        newArticleActivity.title = "Sign"
        newArticleActivity.suggestedInvocationPhrase = "Sign"
        let shortcut = INShortcut(userActivity: newArticleActivity)
        let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)

       }

}


extension SigningSiri:INUIAddVoiceShortcutViewControllerDelegate,INUIEditVoiceShortcutViewControllerDelegate{
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)

    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        
        controller.dismiss(animated: true, completion: nil)

    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
    
        controller.dismiss(animated: true, completion: nil)

    }
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
    
        
        controller.dismiss(animated: true, completion: nil)

    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
    
        controller.dismiss(animated: true, completion: nil)

    }
    
    
}
