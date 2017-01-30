//
//  FormViewController.swift
//  OAuthSwift
//
//  Created by phimage on 23/07/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//


import UIKit
typealias FormViewControllerType = UITableViewController
typealias TextField = UITextField

protocol FormViewControllerProvider {
    var key: String? {get}
    var secret: String? {get}
}
protocol FormViewControllerDelegate: FormViewControllerProvider {
    func didValidate(key: String?, secret: String?)
    func didCancel()
}

class FormViewController: FormViewControllerType {
    var delegate: FormViewControllerDelegate?
    override func viewDidLoad() {
        self.keyTextField.text = self.delegate?.key
        self.secretTextField.text = self.delegate?.secret
        }
    
    @IBOutlet var keyTextField: TextField!
    @IBOutlet var secretTextField: TextField!
    @IBAction func ok(_ sender: AnyObject?) {
        print ("I just pushed LOGIN")
        let key = keyTextField.text
        let secret = secretTextField.text
        delegate?.didValidate(key: key, secret: secret)
    }

    @IBAction func cancel(_ sender: AnyObject?) {
           delegate?.didCancel()
    }
    
    
    
}
