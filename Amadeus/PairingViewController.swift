//
//  PairingViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 10/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit
import Alamofire

class PairingViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var OTPTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pairButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize()
        self.OTPTextField.delegate = self
        self.OTPTextField.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
    }
    
    private func localize()
    {
        self.titleLabel.localized("pairing.text")
        self.pairButton.localized("pairing.button")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if ((textField.text?.count)! >= 11 && string.count == 1)
        {
            return false
        }
        else if (string.count == 0)
        {
            let index: String.Index = (textField.text?.index((textField.text?.endIndex)!, offsetBy: -2))!

            let text = textField.text?[..<index]

            textField.text? = String(describing: text!)

            return false
        }
        else
        {
            textField.text? += " "
            
            return true
        }
    }
    
    private func goToSucess()
    {
        self.performSegue(withIdentifier: "ShowSuccessPairing", sender: self)
    }
    
    private func regenerateManager()
    {
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        
        configuration.httpAdditionalHeaders = ["x-access-token": XACCESSTOKEN]
        
        manager = Alamofire.SessionManager(configuration: configuration)
    }
    
    @IBAction private func goToHome(_ sender: Any)
    {
        self.view.endEditing(true)
        
        let OTPCode = self.OTPTextField.text?.removeSpace
        
        if ((OTPCode?.count)! < 6)
        {
            Utilities.ui.alertView(vc: self, title: "pairing.tokenerror".localized, body: "pairing.tokentooshort".localized)
            return
        }
        
        Network.connection.sendToken(token: OTPCode!)
        { response, token in
            
            guard let rep = response else
            {
                Utilities.ui.alertViewNoResponse(vc: self)
                return
            }
            
            Network.genericReceiver(vc: self, title: "Token Error", response: rep, successHandler:
            {
                if let tok = token
                {
                    Utilities.userDefault.setValue(key: "XACCESSTOKEN", value: tok)
                    XACCESSTOKEN = tok
                    self.regenerateManager()
                }
                
                self.goToSucess()
                
            }, failureHandler:
            {
                self.OTPTextField.text? = ""
                self.OTPTextField.becomeFirstResponder()
            })
        }
    }
}
