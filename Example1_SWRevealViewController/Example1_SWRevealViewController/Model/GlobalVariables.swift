//
//  GlobalVariables.swift
//  Example1_SWRevealViewController
//
//  Created by Mallikarjun on 12/06/20.
//  Copyright © 2020 Mallikarjun. All rights reserved.
//

import Foundation

class GlobalVariables {
    
    // These are the properties you can store in your singleton
    private var myName: String = "bob"
    
    var loggedIn:Bool = true
    
    // Here is how you would get to it without there being a global collision of variables.
    // , or in other words, it is a globally accessable parameter that is specific to the
    // class.
    class var sharedManager: GlobalVariables {
        struct Static {
            static let instance = GlobalVariables()
        }
        return Static.instance
    }
}
