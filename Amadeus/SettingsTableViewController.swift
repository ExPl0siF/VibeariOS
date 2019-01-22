//
//  SettingsTableViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 08/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class SettingsTableViewController: GenericTableViewController
{
    @IBOutlet weak var notificationManager: UITableViewCell!
    @IBOutlet weak var soundManager: UITableViewCell!
    @IBOutlet weak var nightModeCell: UITableViewCell!
    @IBOutlet weak var logOut: UITableViewCell!
    @IBOutlet weak var APIURLCell: UITableViewCell!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize(isAwake: false)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.localize(isAwake: true)
    }
    
    private func localize(isAwake: Bool)
    {
        self.title = "settings.title".localized
        
        if (isAwake == false)
        {
            self.notificationManager.textLabel?.localized("settings.notifcell")
            self.soundManager.textLabel?.localized("settings.soundcell")
            self.nightModeCell.textLabel?.localized("settings.nightmode")
            self.nightModeCell.accessoryView = UISwitch()
            
            if let mySwitch = self.nightModeCell.accessoryView as? UISwitch
            {
                if (NIGHTMODE == true)
                {
                    mySwitch.isOn = true
                }
                else
                {
                    mySwitch.isOn = false
                }
                mySwitch.addTarget(self, action: #selector(self.switchNightMode), for: .valueChanged)
            }
            
            self.logOut.textLabel?.localized("settings.logoutcell")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return NIGHTMODE ? .lightContent : .default
    }
    
    @objc private func switchNightMode()
    {
        if (NIGHTMODE == false)
        {
            NIGHTMODE = true
            
            Utilities.userDefault.setValue(key: "nightMode", value: true)
            
            UINavigationBar.appearance().barTintColor = UIColor.vibearBackground
            UINavigationBar.appearance().tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.vibearBackground
            self.navigationController?.navigationBar.tintColor = UIColor.white
            UITabBar.appearance().backgroundColor = UIColor.vibearBackground
            self.tabBarController?.tabBar.barTintColor = UIColor.vibearBackground
            setNeedsStatusBarAppearanceUpdate()
            //UIApplication.shared.statusBarStyle = .lightContent
        }
        else
        {
            NIGHTMODE = false
            
            Utilities.userDefault.setValue(key: "nightMode", value: false)
            
            UINavigationBar.appearance().barTintColor = UIColor.vibearGray
            UINavigationBar.appearance().tintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.vibearGray
            self.navigationController?.navigationBar.tintColor = UIColor.black
            UITabBar.appearance().backgroundColor = UIColor.vibearGray
            self.tabBarController?.tabBar.barTintColor = UIColor.vibearGray
            setNeedsStatusBarAppearanceUpdate()
            //UIApplication.shared.statusBarStyle = .default
        }
        
        self.view.backgroundColor = UIColor.vibearBackground
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.isLargeTitle(true)
        
        self.notificationManager.backgroundColor = UIColor.vibearBackgroundCell
        self.soundManager.backgroundColor = UIColor.vibearBackgroundCell
        self.nightModeCell.backgroundColor = UIColor.vibearBackgroundCell
        self.logOut.backgroundColor = UIColor.vibearBackgroundCell
        self.APIURLCell.backgroundColor = UIColor.vibearBackgroundCell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 2)
        {
            return 2
        }
        else
        {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
        case 0:
            return "settings.notifheader".localized
        case 1:
            return "settings.soundheader".localized
        case 2:
            return "settings.mischeader".localized
        case 3:
            return "settings.logoutheader".localized
        default:
            return "NULL"
        }
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (tableView.cellForRow(at: indexPath) == logOut)
        {
            Utilities.ui.alertViewYesNo(vc: self, title: "settings.logoutheader".localized, body: "settings.confirmation".localized, yesHandler:
            { _ in
                
                let storyBoard = UIStoryboard(name: "Pairing", bundle: nil)
                
                guard let vc = storyBoard.instantiateViewController(withIdentifier: "LetStart") as? UINavigationController else
                {
                    Utilities.ui.alertView(vc: self, title: "error".localized, body: "error.unknown".localized)
                    return
                }
                
                Network.connection.deleteUser
                { response in
                    
                    guard let rep = response else
                    {
                        Utilities.ui.alertViewNoResponse(vc: self)
                        return
                    }
                    
                    Network.genericReceiver(vc: self, title: "pairingsuccess.error".localized, response: rep, successHandler:
                        {
                            Utilities.userDefault.setValue(key: "IsPaired", value: false)
                            
                            UIView.transition(with: ((UIApplication.shared.delegate?.window)!)!, duration: 1.0, options: .transitionFlipFromTop, animations:
                                {
                                    UIApplication.shared.delegate?.window??.rootViewController = vc
                            })
                    })
                }
            })
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
