//
//  NotificationTableTableViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 07/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class NotificationManagerTableViewController: GenericRefreshTableViewController
{
    var soundList: [GenericSound] = []
    var notificationsList: [String] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize()
        
        self.refreshController.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
    
    private func localize()
    {
        self.title = "notifmanager.title".localized
    }
    
    @objc private func refresh()
    {
        self.loadSound()
    }
    
    private func loadSound()
    {
        Network.sound.list
            { response, genericSoundList in
                
                self.stopRefresh()
                
                guard let rep = response else
                {
                    Utilities.ui.alertView(vc: self, title: "error".localized, body: "network.noresp")
                    return
                }
                
                Network.genericReceiver(vc: self, title: "notifmanager.cannotload".localized, response: rep, successHandler:
                    {
                        self.soundList = genericSoundList!
                        self.indicator.startAnimating()
                        self.loadNotifications()
                })
        }
    }
    
    private func loadNotifications()
    {
        Network.sound.notifications
            { response, soundNotifList in
                
                self.stopRefresh()
                
                guard let rep = response else
                {
                    Utilities.ui.alertView(vc: self, title: "error".localized, body: "network.noresp")
                    return
                }
                
                Network.genericReceiver(vc: self, title: "notifmanager.cannotload".localized, response: rep, successHandler:
                    {
                        self.notificationsList = soundNotifList!
                        self.tableView.reloadData()
                })
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.isLargeTitle(false)

        self.tableView?.reloadData()
        
        self.loadSound()
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return soundList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notifications", for: indexPath)
        
        let row = indexPath.row
        
        cell.textLabel?.text = soundList[row].name
        cell.textLabel?.textColor = UIColor.vibearBlue

        if (self.notificationsList.contains(self.soundList[row].id))
        {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else
        {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
    }
    
    private func changeNotificationState(soundID: String, index: IndexPath, state: UITableViewCell.AccessoryType)
    {
        Network.sound.modifyNotification(id: soundID)
        { response in
            
            guard let rep = response else
            {
                Utilities.ui.alertViewNoResponse(vc: self)
                return
            }
            
            Network.genericReceiver(vc: self, title: "notifmanager.cannotmodify".localized, response: rep, successHandler:
            {
                self.tableView.cellForRow(at: index)?.accessoryType = state
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var state: UITableViewCell.AccessoryType
        
        if (tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark)
        {
            state = .none
        }
        else
        {
            state = .checkmark
        }
        
        self.changeNotificationState(soundID: self.soundList[indexPath.row].id, index: indexPath, state: state)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
