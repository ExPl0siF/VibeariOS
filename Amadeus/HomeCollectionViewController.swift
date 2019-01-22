//
//  HomeCollectionViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 09/06/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit
import AFDateHelper

class HomeCollectionViewController: GenericRefreshCollectionViewController, UICollectionViewDelegateFlowLayout
{
    let cardViewHeight: CGFloat = 128
    let insetCardView: CGFloat = 15
    
    var notificationList: [GenericNotif] = []
    var searchNotificationList: [GenericNotif] = []
    var numberNotificationToday = 0
    
    var search = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.isLargeTitle(true)
        
        self.loadSearchBar()
        
        self.collectionView?.register(UINib(nibName: "HomeCardView", bundle: nil), forCellWithReuseIdentifier: "Cell")
        self.refreshController.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.loadNotifications()

        self.loadSearchbarUI()
        
        if (notificationList.count != 0)
        {
            self.collectionView?.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool)
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.localize()
    }
    
    private func localize()
    {
        self.title = "home.title".localized
    }
    
    @objc private func refresh()
    {
        self.loadNotifications()
    }
    
    private func loadNotifications()
    {
        Network.notifications.list
        { response, genericNotifList in

            self.stopRefresh()
            
            guard let rep = response else
            {
                Utilities.ui.alertViewNoResponse(vc: self)
                return
            }
            
            Network.genericReceiver(vc: self, title: "home.errornotifload".localized, response: rep, successHandler:
            {
                self.notificationList = genericNotifList!
                self.todayElement()
                self.search = false
                self.collectionView?.reloadData()
            })
        }
    }
    
    private func loadSearchBar()
    {
        if #available(iOS 11.0, *)
        {
            let searchController = UISearchController(searchResultsController: nil)
            
            self.definesPresentationContext = true
            self.navigationItem.searchController = searchController
            self.navigationItem.searchController?.searchBar.delegate = self
            self.navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        }
    }
    
    private func loadSearchbarUI()
    {
        if (NIGHTMODE == false)
        {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        else
        {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
        if #available(iOS 11.0, *)
        {
            if let textfield = self.navigationItem.searchController?.searchBar.value(forKey: "searchField") as? UITextField
            {
                if let backgroundview = textfield.subviews.first
                {
                    backgroundview.backgroundColor = UIColor.vibearSearch
                    backgroundview.layer.cornerRadius = 11
                    backgroundview.clipsToBounds = true
                }
            }
        }
    }
    
    private func cellNightMode(cell: HomeCardView)
    {
        cell.backgroundColor = UIColor.vibearBackgroundCell
        
        if (NIGHTMODE == false)
        {
            cell.layer.shadowOpacity = 2.0
            cell.notificationPlace.textColor = UIColor.black
            cell.notificationDate.textColor = UIColor.black
        }
        else
        {
            cell.layer.shadowOpacity = 0.0
            cell.notificationPlace.textColor = UIColor.white
            cell.notificationDate.textColor = UIColor.white
        }
    }

    private func todayElement()
    {
        //notificationList.sort(by: { $0.time.compare($1.time) == .orderedDescending })
        
        self.numberNotificationToday = 0
        
        for element in notificationList
        {
            if (element.time.compare(.isToday))
            {
                self.numberNotificationToday += 1
            }
        }
    }

    private func setHeader(header: GenericHeaderCollectionReusableView, indexPath: IndexPath)
    {
        if (NIGHTMODE == false)
        {
            header.headerLabel.textColor = UIColor.black
        }
        else
        {
            header.headerLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        }

        if (indexPath.section == 0 && self.numberNotificationToday > 0)
        {
            header.headerLabel.text = "home.todaynotif".localized
        }
        else if (indexPath.section == 1 || self.numberNotificationToday == 0)
        {
            header.headerLabel.text = "home.pastnotif".localized
        }

        if (self.notificationList.count == 0)
        {
            header.headerLabel.text = "home.nonotif".localized
        }

        if (self.searchNotificationList.count == 0 && self.search == true)
        {
            header.headerLabel.text = "home.searchnoresults".localized
        }
        else if (self.searchNotificationList.count > 0 && self.search == true)
        {
            header.headerLabel.text = "home.search".localized
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if (kind == UICollectionView.elementKindSectionHeader)
        {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TodayHeader", for: indexPath) as? GenericHeaderCollectionReusableView else
            {
                Utilities.ui.alertView(vc: self, title: "error".localized, body: "error.unknown".localized)
                return UICollectionReusableView()
            }

            self.setHeader(header: header, indexPath: indexPath)

            return header
        }
        else
        {
            return UICollectionReusableView()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        if (self.numberNotificationToday > 0 && self.notificationList.count != self.numberNotificationToday && self.search != true)
        {
            return 2
        }
        else
        {
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if (self.search == true)
        {
            if (section == 0)
            {
                return self.searchNotificationList.count
            }
        }
        else
        {
            if (section == 0 && self.numberNotificationToday > 0)
            {
                return self.numberNotificationToday
            }
            else if (section == 0 && self.numberNotificationToday == 0)
            {
                return self.notificationList.count
            }
            else if (section == 1 && self.numberNotificationToday > 0)
            {
                return self.notificationList.count - self.numberNotificationToday
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (self.collectionView?.frame.size.width)! - self.insetCardView, height: self.cardViewHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let section = indexPath.section
        let row = indexPath.row
        
        guard let cell: HomeCardView = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? HomeCardView else
        {
            Utilities.ui.alertView(vc: self, title: "error".localized, body: "error.unknown".localized)
            return UICollectionViewCell()
        }
        
        self.cellNightMode(cell: cell)
        
        var myRow = 0
        
        if (section == 0)
        {
            myRow = row
        }
        else if (section == 1 && self.numberNotificationToday > 0)
        {
            myRow = row + self.numberNotificationToday
        }
        
        if (self.search == true)
        {
            let time = self.searchNotificationList[myRow].time

            cell.notificationTitle.text = self.searchNotificationList[myRow].title
            cell.notificationPlace.text = self.searchNotificationList[myRow].place
            cell.notificationTime.text = time.toString(format: .custom("HH:mm"))
            cell.notificationDate.text = time.toString(format: .custom("dd/MM/YYYY"))
        }
        else
        {
            let time = self.notificationList[myRow].time
            
            cell.notificationTitle.text = self.notificationList[myRow].title
            cell.notificationPlace.text = self.notificationList[myRow].place
            cell.notificationTime.text = time.toString(format: .custom("HH:mm"))
            cell.notificationDate.text = time.toString(format: .custom("dd/MM/YYYY"))
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        var myRow = 0
        
        if (indexPath.section == 0)
        {
            myRow = indexPath.row
        }
        else if (indexPath.section == 1 && self.numberNotificationToday > 0)
        {
            myRow = indexPath.row + self.numberNotificationToday
        }
        
        if (self.search == false)
        {
            print(self.notificationList[myRow].title)
        }
        else
        {
            print(self.searchNotificationList[myRow].title)
        }
    }
}

extension HomeCollectionViewController: UISearchBarDelegate
{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        if #available(iOS 11.0, *)
        {
            self.search = false
            self.navigationItem.searchController?.searchBar.resignFirstResponder()
            self.navigationItem.searchController?.searchBar.text = ""
            self.collectionView?.reloadData()
            self.navigationItem.searchController?.searchBar.showsCancelButton = false
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        if #available(iOS 11.0, *)
        {
            self.search = false
            self.navigationItem.searchController?.searchBar.resignFirstResponder()
            self.navigationItem.searchController?.searchBar.text = ""
            self.dismissKeyboard()
            self.collectionView?.reloadData()
            self.navigationItem.searchController?.searchBar.showsCancelButton = false
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        if #available(iOS 11.0, *)
        {
            self.navigationItem.searchController?.searchBar.showsCancelButton = true
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.searchNotificationList.removeAll()

        if (searchText.isEmpty)
        {
            self.search = false
            self.collectionView?.reloadData()
        }
        else
        {
            self.search = true

            for element in notificationList
            {
                if (element.title.lowercased().range(of: searchText.lowercased()) != nil)
                {
                    self.searchNotificationList.append(element)
                }
            }

            self.collectionView?.reloadData()
        }
    }
}
