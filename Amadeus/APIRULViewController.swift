//
//  APIRULViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 31/03/2018.
//  Copyright © 2018 Vibear Inc. All rights reserved.
//

import UIKit

class APIRULViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var APIRULTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.APIRULTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func changeAPIURL(_ sender: Any)
    {
        if (self.APIRULTextField.text != "" && self.APIRULTextField.text != nil)
        {
            if (self.APIRULTextField.text?.isURL)!
            {
                APIURL = self.APIRULTextField.text!
                Utilities.userDefault.setValue(key: "APIURL", value: APIURL)
                Utilities.ui.alertView(vc: self, title: "Perfect", body: "APIURL is now changed", completionHandler: { _ in self.navigationController?.popViewController(animated: true) })
            }
            else
            {
                Utilities.ui.alertView(vc: self, title: "Error", body: "This is not a valid url")
            }
        }
        else
        {
            Utilities.ui.alertView(vc: self, title: "Error", body: "Please enter an APIURL")
        }
    }
    
    @IBAction func resetAPIURL(_ sender: Any)
    {
        APIURL = "https://api.vibear.ml/"
        Utilities.userDefault.setValue(key: "APIURL", value: APIURL)
        Utilities.ui.alertView(vc: self, title: "Perfect", body: "APIURL is now changed", completionHandler: { _ in self.navigationController?.popViewController(animated: true) })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.view.backgroundColor = UIColor.vibearBackground
        
        self.title = "Change URL"
        
        self.APIRULTextField.text = APIURL
        
        self.isLargeTitle(false)
    }
}
