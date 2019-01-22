//
//  SearchBoxViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 10/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class SearchBoxViewController: UIViewController
{
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var ssidList: [WifiList] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize()
    }
    
    private func localize()
    {
        self.titleLabel.localized("searchbox.text")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.activityIndicator.startAnimating()
        self.doSearchBox()
    }
    
    private func doSearchBox()
    {
        Network.connection.searchBox
            { response in
                
                self.activityIndicator.stopAnimating()
            
                guard let rep = response else
                {
                    Utilities.ui.alertViewYesNo(vc: self, title: "error".localized, body: "searchbox.nobox".localized, yesHandler:
                    { _ in
                        
                        self.activityIndicator.startAnimating()
                        self.doSearchBox()
                        
                    }, noHandler:
                    { _ in
                        
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    })
                    return
                }
                
                Network.genericReceiver(vc: self, response: rep, successHandler:
                {
                    self.searchInternet()
                    self.activityIndicator.startAnimating()
                })
            }
    }
    
    private func searchInternet()
    {
        Network.connection.checkInternet(completionHandler:
            { response, genericWifiList in
                
                self.activityIndicator.stopAnimating()
                
                guard let rep = response else
                {
                    Utilities.ui.alertViewNoResponse(vc: self)
                    return
                }
                
                if (rep.message == "Connected to internet")
                {
                    self.goToPairing()
                    return
                }
                
                Network.genericReceiver(vc: self, title: "home.errornotifload".localized, response: rep, successHandler:
                    {
                        self.ssidList = genericWifiList!
                        self.goToWifi()
                })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "GoToWifi"
        {
            guard let vc = segue.destination as? WiFiViewController else
            {
                Utilities.ui.alertView(vc: self, title: "error".localized, body: "error.unknown".localized)
                return
            }
                
            vc.pickerWifi = self.ssidList
        }
    }
    
    private func goToPairing()
    {
        self.performSegue(withIdentifier: "GoToPairing", sender: self)
    }
    
    private func goToWifi()
    {
        self.performSegue(withIdentifier: "GoToWifi", sender: self)
    }
}
