//
//  Storyboards.swift
//  OAuthSwift
//
//  Created by phimage on 23/07/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation

    import UIKit
    public typealias OAuthStoryboard = UIStoryboard
    public typealias OAuthStoryboardSegue = UIStoryboardSegue
    



struct Storyboards {
    struct Main {
        
        static let identifier = "Storyboard"
        
        static var storyboard: OAuthStoryboard {
            return OAuthStoryboard(name: self.identifier, bundle: nil)
        }
        
        static func instantiateForm() -> FormViewController {
            
                return self.storyboard.instantiateViewController(withIdentifier: "Form") as! FormViewController
            
        }

        static let FormSegue = "form"

    }
}
