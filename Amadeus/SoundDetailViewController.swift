//
//  SoundDetailViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 15/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class SoundDetailViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var soundNameTextField: UITextField!
    @IBOutlet weak var changeNameButton: UIButton!
    @IBOutlet weak var deleteSoundButton: UIButton!
    
    var sound = GenericSound(soundName: "", soundID: "", notification: false)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize()
        
        self.soundNameTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    private func localize()
    {
        self.soundNameTextField.placeholder = "sounddetail.placeholder".localized
        self.changeNameButton.localized("sounddetail.buttonchange")
        self.deleteSoundButton.localized("sounddetail.buttondelete")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationItem.title = sound.name
        self.soundNameTextField.text = sound.name
        
        self.view.backgroundColor = UIColor.vibearBackground
    }
    
    @IBAction private func changeSoundName(_ sender: Any)
    {
        if (sound.name == soundNameTextField.text)
        {
            Utilities.ui.alertView(vc: self, title: "error".localized, body: "sounddetail.samename".localized)
            return
        }
        
        Network.sound.modify(id: sound.id, name: soundNameTextField.text!)
        { response in
            
            guard let rep = response else
            {
                Utilities.ui.alertViewNoResponse(vc: self)
                return
            }
            
            Network.genericReceiver(vc: self, title: "sounddetail.cannotmodify".localized, response: rep, successHandler:
            {
                Utilities.ui.alertView(vc: self, title: "sounddetail.ok.title".localized, body: "sounddetail.ok.text".localized, completionHandler:
                { _ in
                    _ = self.navigationController?.popViewController(animated: true)
                })
            })
        }
    }
    
    @IBAction private func deleteSound(_ sender: Any)
    {
        Utilities.ui.alertViewYesNo(vc: self, title: "sounddetail.delete.title".localized, body: "sounddetail.delete.text".localized, yesHandler:
            { _ in

                Network.sound.delete(id: self.sound.id)
                { response in
                    
                    guard let rep = response else
                    {
                        Utilities.ui.alertViewNoResponse(vc: self)
                        return
                    }
                    
                    Network.genericReceiver(vc: self, title: "sounddetail.delete.error.title".localized, response: rep, successHandler:
                        {
                            Utilities.ui.alertView(vc: self, title: "sounddetail.delete.ok.title".localized, body: "sounddetail.delete.ok.text".localized, completionHandler:
                                { _ in
                                    _ = self.navigationController?.popViewController(animated: true)
                            })
                    })
                }
        })
    }
}
