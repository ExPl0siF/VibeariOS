//
//  WiFiViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 13/11/2018.
//  Copyright © 2018 Vibear Inc. All rights reserved.
//

import UIKit

class WiFiViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var selectWifiLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var wifiPicker: UIPickerView!
    @IBOutlet weak var pickerPassword: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var pickerWifi: [WifiList] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize()
        
        self.wifiPicker.delegate = self
        self.wifiPicker.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return self.pickerWifi.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    {
        let titleData = self.pickerWifi[row].ssid
        
        let myTitle: NSAttributedString
        
        if (NIGHTMODE == true)
        {
            myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        else
        {
            myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        }
        
        return myTitle
    }
    
    private func localize()
    {
        //self.titleLabel.localized("searchbox.text")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        //activityIndicator.startAnimating()
        //self.doSearchBox()
    }
    
    @IBAction func goToNext(_ sender: Any)
    {
        if (self.pickerPassword.text == "")
        {
            Utilities.ui.alertView(vc: self, title: "lol", body: "No password")
            return
        }
        
        Network.connection.setWifi(ssid: self.pickerWifi[self.wifiPicker.selectedRow(inComponent: 0)].ssid, password: self.pickerPassword.text!, completionHandler:
        { response in
            
            guard let rep = response else
            {
                return
            }
            
            Network.genericReceiver(vc: self, response: rep, successHandler:
                {
                    self.goToReboot()
            })
        })
    }
    
    private func goToReboot()
    {
        self.performSegue(withIdentifier: "GoToRebootFromWiFi", sender: self)
    }
}
