//
//  MonitoringTableViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 08/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class MonitoringTableViewController: GenericRefreshTableViewController
{
    var micList: [GenericMic] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.refreshController.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.localize()
    }
    
    private func localize()
    {
        self.title = "monitoring.title".localized
    }
    
    @objc private func refresh()
    {
        self.loadMic()
    }
    
    private func micFilter()
    {
        var tmpMicList: [GenericMic] = []
        
        for mic in self.micList where mic.configured != false
        {
            tmpMicList.append(mic)
        }
        
        self.micList = tmpMicList
        self.tableView.reloadData()
    }
    
    private func loadMic()
    {
        Network.micro.list
            { response, genericSoundList in
                
                self.stopRefresh()
                
                guard let rep = response else
                {
                    Utilities.ui.alertViewNoResponse(vc: self)
                    return
                }
                
                Network.genericReceiver(vc: self, title: "monitoring.error".localized, response: rep, successHandler:
                    {
                        self.micList = genericSoundList!
                        self.micFilter()
                })
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.isLargeTitle(true)

        self.tableView?.reloadData()
        
        self.loadMic()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.micList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Mic", for: indexPath)
        
        let row = indexPath.row
        
        cell.textLabel?.text = micList[row].name
        cell.textLabel?.textColor = UIColor.vibearBlue
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .destructive, title: "monitoring.action".localized)
        { _, index in
            
            Utilities.ui.alertViewYesNo(vc: self, title: "monitoring.action.title".localized, body: "monitoring.action.text".localized, yesHandler:
                { _ in
                    Network.micro.delete(id: self.micList[index.row].id)
                    { response in
                        
                        guard let rep = response else
                        {
                            Utilities.ui.alertViewNoResponse(vc: self)
                            return
                        }
                        
                        Network.genericReceiver(vc: self, title: "monitoring.deleteerror".localized, response: rep, successHandler:
                            {
                                self.tableView.beginUpdates()
                                self.micList.remove(at: index.row)
                                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                                self.tableView.endUpdates()
                        }, failureHandler:
                            {
                                tableView.setEditing(false, animated: true)
                        })
                    }
            }, noHandler:
                { _ in
                    
                    tableView.setEditing(false, animated: true)
            })
        }
        
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "showMicDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showMicDetail"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow
            {
                guard let vc = segue.destination as? MicDetailViewController else
                {
                    Utilities.ui.alertView(vc: self, title: "error".localized, body: "error.unknown".localized)
                    return
                }
                
                vc.micro = self.micList[indexPath.row]
            }
        }
    }
}
