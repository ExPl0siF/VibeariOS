//
//  MicDetailViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 02/06/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class MicDetailViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var micNameTextField: UITextField!
    @IBOutlet weak var changeNameButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var batteryProgress: BatteryView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    var micro = GenericMic(micName: "", micID: "", battery: -1, state: -1, configured: false)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize()
        
        self.micNameTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    private func localize()
    {
        self.micNameTextField.placeholder = "micdetail.placeholder".localized
        self.changeNameButton.localized("micdetail.buttonchange")
        self.deleteButton.localized("micdetail.buttondelete")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.isLargeTitle(false)
        self.navigationItem.title = micro.name
        self.micNameTextField.text = micro.name
        self.setValue()
        
        self.view.backgroundColor = UIColor.vibearBackground
    }
    
    func setValue()
    {
        if (micro.state == 0)
        {
            self.stateLabel.text = "micdetail.state.error".localized
            self.stateLabel.textColor = UIColor.red
        }
        else if (micro.state == 1)
        {
            self.stateLabel.text = "micdetail.state.problem".localized
            self.stateLabel.textColor = UIColor.orange
        }
        else if (micro.state == 2)
        {
            self.stateLabel.text = "micdetail.state.isok".localized
            self.stateLabel.textColor = UIColor.white
        }
        
        self.batteryProgress.level = micro.battery
        self.percentageLabel.text = String(micro.battery) + " %"
        self.batteryProgress.bringSubviewToFront(self.percentageLabel)
    }
    
    @IBAction private func changeSoundName(_ sender: Any)
    {
        if (micro.name == micNameTextField.text)
        {
            Utilities.ui.alertView(vc: self, title: "error".localized, body: "micdetail.samename".localized)
            return
        }
        
        Network.micro.modify(id: micro.id, name: micNameTextField.text!)
        { response in
            
            guard let rep = response else
            {
                Utilities.ui.alertViewNoResponse(vc: self)
                return
            }
            
            Network.genericReceiver(vc: self, title: "micdetail.cannotmodify".localized, response: rep, successHandler:
                {
                    Utilities.ui.alertView(vc: self, title: "micdetail.ok.title".localized, body: "micdetail.ok.text".localized, completionHandler:
                        { _ in
                            _ = self.navigationController?.popViewController(animated: true)
                    })
            })
        }
    }
    
    @IBAction private func deleteSound(_ sender: Any)
    {
        Utilities.ui.alertViewYesNo(vc: self, title: "micdetail.delete.title".localized, body: "micdetail.delete.text".localized, yesHandler:
            { _ in
                
                Network.micro.delete(id: self.micro.id)
                { response in
                    
                    guard let rep = response else
                    {
                        Utilities.ui.alertViewNoResponse(vc: self)
                        return
                    }
                    
                    Network.genericReceiver(vc: self, title: "micdetail.delete.error.title".localized, response: rep, successHandler:
                        {
                            Utilities.ui.alertView(vc: self, title: "micdetail.delete.ok.title".localized, body: "micdetail.delete.ok.text".localized, completionHandler:
                            { _ in
                                
                                _ = self.navigationController?.popViewController(animated: true)
                            })
                    })
                }
        })
    }
}
