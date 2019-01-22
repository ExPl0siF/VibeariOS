//
//  AddMicNameViewController.swift
//  Amadeus
//
//  Created by Theo on 21/08/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class AddMicNameViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var micNameLabel: UILabel!
    @IBOutlet weak var micNameTextField: UITextField!
    @IBOutlet weak var finishButton: UIButton!

    var micro = GenericMic(micName: "", micID: "", battery: -1, state: -1, configured: false)

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.micNameTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)

        self.view.backgroundColor = UIColor.vibearBackground

        self.colorize()

        self.localize()
        
        self.modifyLight(light: true)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(true)
        
        self.modifyLight(light: false)
    }
    
    private func modifyLight(light: Bool)
    {
        Network.micro.light(id: self.micro.id, light: light)
        { response in
            
            guard let rep = response else
            {
                Utilities.ui.alertViewNoResponse(vc: self)
                return
            }
                
            Network.genericReceiver(vc: self, title: "addmicname.errorlight".localized, response: rep)
        }
    }

    func colorize()
    {
        if (NIGHTMODE == true)
        {
            self.titleLabel.textColor = UIColor.white
        }
        else
        {
            self.titleLabel.textColor = UIColor.black
        }
    }

    func localize()
    {
        self.title = "addmicname.title".localized
        self.titleLabel.localized("addmicname.text")
        self.micNameLabel.localized("addmicname.micnamelabel")
        self.finishButton.localized("addmicname.finish")
    }

    @IBAction func launchFinish(_ sender: Any)
    {
        if (self.micNameTextField.text == "")
        {
            Utilities.ui.alertView(vc: self, title: "error".localized, body: "addmicname.noname".localized)
            return
        }

        self.finishButton.isEnabled = false
        self.dismissKeyboard()

        Network.micro.modify(id: micro.id, name: self.micNameTextField.text!)
        { response in

            guard let rep = response else
            {
                Utilities.ui.alertViewNoResponse(vc: self)
                return
            }

            Network.genericReceiver(vc: self, title: "addmicname.cannotsave".localized, response: rep, successHandler:
                {
                    self.dismiss(animated: true, completion: nil)
            }, failureHandler:
                {
                    self.finishButton.isEnabled = true
            })
        }
    }

    @IBAction func cancelAdding(_ sender: Any)
    {
        self.modifyLight(light: false)
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
