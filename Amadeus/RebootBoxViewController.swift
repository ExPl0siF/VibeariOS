//
//  RebootBoxViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 15/11/2018.
//  Copyright © 2018 Vibear Inc. All rights reserved.
//

import UIKit

class RebootBoxViewController: UIViewController
{
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func goBackButton(_ sender: Any) {
    }
    
    var timer: Timer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        self.activityIndicator.startAnimating()
        
        perform(#selector(timerActivation), with: nil, afterDelay: 5.0)
    }
    
    @objc private func timerActivation()
    {
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.doSearchBox), userInfo: nil, repeats: true)
    }
    
    @objc private func doSearchBox()
    {
        Network.connection.checkInternet
            { (response, _) in
            
                guard let rep = response else
                {
                    return
                }
                
                if (rep.status == "success" && rep.message == "Connected to internet")
                {
                    self.activityIndicator.stopAnimating()
                    self.timer!.invalidate()
                    Network.connection.searchBox
                        { response in
                            
                            guard let rep = response else
                            {
                                return
                            }
                            
                            if (rep.status == "success")
                            {
                                self.performSegue(withIdentifier: "GoToPairingFromReboot", sender: self)
                            }
                    }
                }
                else if (rep.status == "success" && rep.message == "SSID List")
                {
                    self.activityIndicator.stopAnimating()
                    self.timer!.invalidate()
                    Utilities.ui.alertView(vc: self, title: "Wrong Wifi Password", body: "You have to renter your wifi password", completionHandler: { (_) in
                      _ = self.navigationController?.popViewController(animated: true)
                    })
                }
            }
    }
}
