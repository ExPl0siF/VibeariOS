//
//  AddMicViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 02/06/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class AddMicTableViewController: GenericRefreshTableViewController
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
        self.title = "addmic.title".localized
    }

    @objc private func refresh()
    {
        self.loadMic()
    }

    private func micFilter()
    {
        var tmpMicList: [GenericMic] = []
        
        for mic in self.micList where mic.configured != true
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

                Network.genericReceiver(vc: self, title: "addmic.error".localized, response: rep, successHandler:
                    {
                        self.micList = genericSoundList!
                        self.micFilter()
                })
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)

        self.navigationItem.hidesBackButton = true

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "mic", for: indexPath)

        let row = indexPath.row

        cell.textLabel?.text = micList[row].name
        cell.textLabel?.textColor = UIColor.vibearBlue
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (self.micList.count == 0)
        {
            return "addmic.nomic".localized
        }
        else
        {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "showMicName", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showMicName"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow
            {
                guard let vc = segue.destination as? AddMicNameViewController else
                {
                    Utilities.ui.alertView(vc: self, title: "error".localized, body: "error.unknown".localized)
                    return
                }

                vc.micro = self.micList[indexPath.row]
            }
        }
    }
    
    @IBAction func cancelAdding(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
