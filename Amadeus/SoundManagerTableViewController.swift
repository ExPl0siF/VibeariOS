//
//  AddSoundTableViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 15/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class SoundManagerTableViewController: GenericRefreshTableViewController
{
    var soundList: [GenericSound] = []
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize()
        
        self.refreshController.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
    
    private func localize()
    {
        self.navBarItem.backBarButtonItem?.title? = "soundmanager.back".localized
        self.navBarItem.title = "soundmanager.title".localized
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
                    Utilities.ui.alertViewNoResponse(vc: self)
                    return
                }
                
                Network.genericReceiver(vc: self, title: "soundmanager.cannotload".localized, response: rep, successHandler:
                {
                    self.soundList = genericSoundList!
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
        return self.soundList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Sound", for: indexPath)
        
        let row = indexPath.row
        
        cell.textLabel?.text = soundList[row].name
        cell.textLabel?.textColor = UIColor.vibearBlue
        cell.backgroundColor = UIColor.vibearBackgroundCell
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .destructive, title: "soundmanager.action".localized)
        { _, index in
            
            Utilities.ui.alertViewYesNo(vc: self, title: "soundmanager.action.title".localized, body: "soundmanager.action.text".localized, yesHandler:
            { _ in
                Network.sound.delete(id: self.soundList[index.row].id)
                    { response in
                        
                        guard let rep = response else
                        {
                            Utilities.ui.alertViewNoResponse(vc: self)
                            return
                        }
                        
                        Network.genericReceiver(vc: self, title: "soundmanager.deleteerror".localized, response: rep, successHandler:
                            {
                                self.tableView.beginUpdates()
                                self.soundList.remove(at: index.row)
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
        self.performSegue(withIdentifier: "showSoundDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showSoundDetail"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow
            {
                guard let vc = segue.destination as? SoundDetailViewController else
                {
                    Utilities.ui.alertView(vc: self, title: "error".localized, body: "error.unknown".localized)
                    return
                }
                
                vc.sound = self.soundList[indexPath.row]
            }
        }
    }
}
