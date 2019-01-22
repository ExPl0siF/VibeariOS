//
//  Extension.swift
//  Amadeus
//
//  Created by Theo Caselli on 18/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import Foundation
import UIKit

extension String
{
    var removeSpace: String
    {
        return components(separatedBy: .whitespaces).joined()
    }
    
    var localized: String
    {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(value: String) -> String
    {
        return String(format: NSLocalizedString(self, comment: ""), NSLocalizedString(value, comment: ""))
    }
    
    var isURL: Bool
    {
        do
        {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            
            if let res = matches.first
            {
                return res.resultType == .link && res.range.location == 0 && res.range.length == self.count
            }
            else
            {
                return false
            }
        }
        catch
        {
            return false
        }
    }
}

extension UILabel
{
    func localized(_ id: String)
    {
        self.text = NSLocalizedString(id, comment: "")
    }
    
    func localized(_ id: String, _ value: String)
    {
        self.text = String(format: NSLocalizedString(id, comment: ""), NSLocalizedString(value, comment: ""))
    }
}

extension UIButton
{
    func localized(_ id: String)
    {
        self.setTitle(NSLocalizedString(id, comment: ""), for: .normal)
    }
    
    func localized(_ id: String, _ value: String)
    {
        self.setTitle(String(format: NSLocalizedString(id, comment: ""), NSLocalizedString(value, comment: "")), for: .normal)
    }
}

extension UIBarButtonItem
{
    func localized(_ id: String)
    {
        self.title = NSLocalizedString(id, comment: "")
    }
    
    func localized(_ id: String, _ value: String)
    {
        self.title = String(format: NSLocalizedString(id, comment: ""), NSLocalizedString(value, comment: ""))
    }
}

extension UITextField
{
    func localized(_ id: String)
    {
        self.placeholder = NSLocalizedString(id, comment: "")
    }
    
    func localized(_ id: String, _ value: String)
    {
        self.placeholder = String(format: NSLocalizedString(id, comment: ""), NSLocalizedString(value, comment: ""))
    }
}

extension UIColor
{
    class var vibearBlue: UIColor
    {
        return UIColor.rgb(fromHex: 0x19B49B)
    }
    
    class var vibearBackground: UIColor
    {
        if (NIGHTMODE == false)
        {
            return UIColor(red: 0.937, green: 0.937, blue: 0.956, alpha: 1)
        }
        else
        {
            return UIColor.rgb(fromHex: 0x222A35)
        }
    }
    
    class var vibearBackgroundCell: UIColor
    {
        if (NIGHTMODE == false)
        {
            return UIColor.white
        }
        else
        {
            return UIColor.rgb(fromHex: 0x3C4A5C)
        }
    }
    
    class var vibearSearch: UIColor
    {
        if (NIGHTMODE == false)
        {
            return UIColor.rgb(fromHex: 0xF0F0F0)
        }
        else
        {
            return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }
    }
    
    class var vibearGray: UIColor
    {
        return UIColor.rgb(fromHex: 0xF4F4F4)
    }
    
    class func rgb(fromHex: Int) -> UIColor
    {
        
        let red =   CGFloat((fromHex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((fromHex & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(fromHex & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIViewController
{
    func hideKeyboardWhenTappedAround()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.dismissKeyboard()
        return false
    }
    
    func isLargeTitle(_ choice: Bool)
    {
        if #available(iOS 11.0, *)
        {
            self.navigationController?.navigationBar.prefersLargeTitles = choice
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.vibearBlue]
        }
    }
}

class GenericHeaderCollectionReusableView: UICollectionReusableView
{
    @IBOutlet weak var headerLabel: UILabel!
}

protocol GenericRefreshView
{
    var indicator: UIActivityIndicatorView { get set }
    var refreshController: UIRefreshControl { get set }
    
    func setupActivityIndicator()
    func setupRefreshController()
    func moreSpecificRefresh()
    func stopRefresh()
}

extension GenericRefreshView where Self: UIViewController
{
    func setupActivityIndicator()
    {
        self.indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.indicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.indicator.center.x = self.view.center.x
        self.indicator.center.y = self.view.center.y
        self.indicator.backgroundColor = UIColor.clear
        self.indicator.color = UIColor.vibearBlue
        self.indicator.hidesWhenStopped = true
        self.view.addSubview(self.indicator)
    }
    
    func moreSpecificRefresh()
    {
        //Implementation in GenericCollection or GenericTable
    }
    
    func setupRefreshController()
    {
        self.refreshController.tintColor = UIColor.vibearBlue
        
        if #available(iOS 11.0, *)
        {
            self.refreshController.backgroundColor = self.navigationController?.navigationBar.backgroundColor
        }
        else
        {
            self.refreshController.backgroundColor = UIColor.vibearBackgroundCell
        }
        
        self.refreshController.attributedTitle = NSAttributedString(string: "pulltorefresh".localized)
        
        self.moreSpecificRefresh()
    }
    
    func stopRefresh()
    {
        self.refreshController.endRefreshing()
        self.indicator.stopAnimating()
    }
}

class GenericRefreshCollectionViewController: UICollectionViewController, GenericRefreshView
{
    var indicator = UIActivityIndicatorView()
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.setupRefreshController()
        
        self.indicator.startAnimating()
        
        self.collectionView?.backgroundColor = UIColor.vibearBackground
    }
    
    func moreSpecificRefresh()
    {
        if #available(iOS 10.0, *)
        {
            self.collectionView?.refreshControl = self.refreshController
        }
        else
        {
            self.collectionView?.insertSubview(self.refreshController, at: 0)
        }
    }
}

class GenericTableViewController: UITableViewController
{
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.tableView?.backgroundColor = UIColor.vibearBackground
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.backgroundColor = UIColor.vibearBackgroundCell
    }
}

class GenericRefreshTableViewController: GenericTableViewController, GenericRefreshView
{
    var indicator = UIActivityIndicatorView()
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupActivityIndicator()
        
        if let myTabBarHeight = self.tabBarController?.tabBar.frame.size.height
        {
            self.indicator.center.y = self.view.center.y - myTabBarHeight - (self.navigationController?.navigationBar.frame.size.height)! / 2
        }
        else
        {
            self.indicator.center.y = self.view.center.y - (self.navigationController?.navigationBar.frame.size.height)! / 2
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.setupRefreshController()
        
        self.indicator.startAnimating()
    }
    
    func moreSpecificRefresh()
    {
        if #available(iOS 10.0, *)
        {
            self.tableView?.refreshControl = self.refreshController
        }
        else
        {
            self.tableView?.insertSubview(self.refreshController, at: 0)
        }
    }
}
