//
//  MainTabBarViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 08/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.sendToken()
    }

    private func sendToken()
    {
        let FCMToken: String = Utilities.userDefault.getValue(key: "FCMToken")!

        Network.connection.sendUserData(FCMToken: FCMToken, completionHandler: { _ in })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return NIGHTMODE ? .lightContent : .default
    }
    
    private func changeColor(color: UIColor)
    {
        UINavigationBar.appearance().barTintColor = color
        self.navigationController?.navigationBar.barTintColor = color
        UITabBar.appearance().backgroundColor = color
        self.tabBar.barTintColor = color

        if (color == UIColor.vibearBackground)
        {
            UINavigationBar.appearance().tintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.white
            setNeedsStatusBarAppearanceUpdate()
            //UIApplication.shared.statusBarStyle = .lightContent
        }
        else
        {
            UINavigationBar.appearance().tintColor = UIColor.black
            self.navigationController?.navigationBar.tintColor = UIColor.black
            setNeedsStatusBarAppearanceUpdate()
            //UIApplication.shared.statusBarStyle = .default
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        //Fix for IOS 9
        UITabBar.appearance().tintColor = UIColor.vibearBlue

        let color = NIGHTMODE ? UIColor.vibearBackground : UIColor.vibearGray

        self.changeColor(color: color)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
