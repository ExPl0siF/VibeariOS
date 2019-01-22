//
//  PairingSuccessViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 11/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class PairingSuccessViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonGoHome: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize()
    }
    
    private func localize()
    {
        self.titleLabel.localized("pairingsuccess.text")
        self.buttonGoHome.localized("pairingsuccess.button")
    }
    
    @IBAction private func goToHome(_ sender: Any)
    {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "MainTabBar") as? UINavigationController else
        {
            Utilities.ui.alertView(vc: self, title: "error".localized, body: "error.unknown".localized)
            return
        }
        
        let FCMToken: String = Utilities.userDefault.getValue(key: "FCMToken")!
        
        Network.connection.sendUserData(FCMToken: FCMToken)
        { response in
            
            guard let rep = response else
            {
                Utilities.ui.alertViewNoResponse(vc: self)
                return
            }
            
            Network.genericReceiver(vc: self, title: "pairingsuccess.error".localized, response: rep, successHandler:
            {
                Utilities.userDefault.setValue(key: "IsPaired", value: true)
                
                UIView.transition(with: ((UIApplication.shared.delegate?.window)!)!, duration: 1.0, options: .transitionFlipFromTop, animations:
                {
                        UIApplication.shared.delegate?.window??.rootViewController = vc
                })
            })
        }
    }
}
