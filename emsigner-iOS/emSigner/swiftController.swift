//------------------------------------------------------------------------------
//
// Created by EMUDHRA on 12/12/18.// All rights reserved.
//
// This code is licensed under the MIT License.
//

import UIKit
import MSAL
import MBProgressHUD

/// 😃 A View Controller that will respond to the events of the Storyboard.


class swiftController: UIViewController, UITextFieldDelegate, URLSessionDelegate {
    
    // Update the below to your client ID you received in the portal.
    let kClientID = "b0acf5d9-ec86-4f61-badb-3479d326b345"
    
    let kGraphEndpoint = "https://graph.microsoft.com/v1.0/me/"
    let kAuthority = "https://login.microsoftonline.com/common"
    
    let kScopes: [String] = ["https://graph.microsoft.com/user.read",""]
    
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    var login: ViewController = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.updateSignOutButton(enabled: !self.accessToken.isEmpty)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let minimumVersion = OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 1)
        if ProcessInfo().isOperatingSystemAtLeast(minimumVersion) {
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                // topController should now be your topmost view controller
            }
            
            
            do {
                try self.initMSAL()
            } catch let error {
                print(error)
            }
            
            callGraphAPI()
        }
        
    }
}


// MARK: Initialization

extension swiftController {
    
    @objc func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
            
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: nil, authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        
        self.webViewParamaters = MSALWebviewParameters(parentViewController: self)
    }
    
    func initWebViewParams() {
        self.webViewParamaters = MSALWebviewParameters(parentViewController: self)
    }
}


// MARK: Acquiring and using token

extension swiftController {
    
    @objc func callGraphAPI() {
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        
        guard let currentAccount = self.currentAccount() else {
            // We check to see if we have a current logged in account.
            // If we don't, then we need to sign someone in.
            acquireTokenInteractively()
            return
        }
        
        acquireTokenInteractively()
    }
    
    func acquireTokenInteractively() {
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        
        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount;
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                loadingNotification?.hide(true)
                
                return
            } else {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                loadingNotification?.hide(true)
            }
            
            
            guard
                let result = result else {
                    
                    return
            }
            
            self.accessToken = result.accessToken
            self.getContentWithToken()
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            
            self.getContentWithToken()
        }
    }
    
    func getContentWithToken() {
        
        let url = URL(string: kGraphEndpoint)
        var request = URLRequest(url: url!)
        
        
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                
                return
            }
            
            guard let resultNew = result as? [String:Any] else {
                return
            }
            
            let email = resultNew["mail"]  as! String
            print(email)
            self.login.login(withOffice365: email)
            
        }.resume()
    }
    
}


// MARK: Get account and removing cache

extension swiftController {
    
    func currentAccount() -> MSALAccount? {
        
        do {
            
            let cachedAccounts = try self.applicationContext?.allAccounts()
            
            if !(cachedAccounts?.isEmpty)! {
                return cachedAccounts?.first
            }
            
        } catch let error as NSError {
       
        }
        
        
        return nil
    }
    
    /**
     This action will invoke the remove account APIs to clear the token cache
     to sign out a user from this application.
     */
    @objc func signOut() {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let account = self.currentAccount()
        
        do {
            
            /**
             Removes all tokens from the cache for this application for the provided account
             
             - account:    The account to remove from the cache
             */
            try self.applicationContext?.remove(self.currentAccount()!)
            
            self.updateLogging(text: "")
            self.updateSignOutButton(enabled: false)
            self.accessToken = ""
            
            
        } catch let error as NSError {
            print(error)
            
        }
    }
}


// MARK: UI Helpers
extension swiftController {
    
    @objc func initForGraph(){
        
        do {
            try self.initMSAL()
        } catch let error {
            print(error)
        }
        
        callGraphAPI()
        
    }
    
    func updateLogging(text : String) {
        
        if Thread.isMainThread {
            
        } else {
            DispatchQueue.main.async {
                
            }
        }
    }
    
    func updateSignOutButton(enabled : Bool) {
        if Thread.isMainThread {
            
        } else {
            DispatchQueue.main.async {
                
            }
        }
    }
}
