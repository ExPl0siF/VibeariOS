//
//  AppDelegate.swift
//  Amadeus
//
//  Created by Theo Caselli on 07/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        self.window = UIWindow(frame: UIScreen.main.bounds)

        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *)
        {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        }
        else
        {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 25
        configuration.timeoutIntervalForResource = 25
        
        if let token: String = Utilities.userDefault.getValue(key: "XACCESSTOKEN")
        {
            XACCESSTOKEN = token
        }
        
        configuration.httpAdditionalHeaders = ["x-access-token": XACCESSTOKEN]
        
//        let pathToCert = Bundle.main.url(forResource: "cert", withExtension: "der")
//
//        let localCertificate = NSData(contentsOf: pathToCert!)
//
//        let serverTrustPolicy = ServerTrustPolicy.pinCertificates(
//            certificates: [SecCertificateCreateWithData(nil, localCertificate!)!],
//            validateCertificateChain: true,
//            validateHost: true
//        )
//        let serverTrustPolicies = [ "theosmacbook.local": serverTrustPolicy ]
//
//        manager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))

        manager = Alamofire.SessionManager(configuration: configuration)
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        let isPaired: Bool = Utilities.userDefault.getValue(key: "IsPaired")!
        
        if let testURL: String = Utilities.userDefault.getValue(key: "APIURL")
        {
            APIURL = testURL
        }
        
        if (isPaired)
        {
            let storyBoard = UIStoryboard(name: "Home", bundle: nil)
            
            Utilities.misc.resetBadge()

            guard let vc = storyBoard.instantiateViewController(withIdentifier: "MainTabBar") as? UINavigationController else
            {
                print("error".localized)
                return false
            }
            
            NIGHTMODE = Utilities.userDefault.getValue(key: "nightMode")!
            
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        else
        {
            let storyBoard = UIStoryboard(name: "Pairing", bundle: nil)
            
            guard let vc = storyBoard.instantiateViewController(withIdentifier: "LetStart") as? UINavigationController else
            {
                print("error".localized)
                return false
            }
            
            Utilities.userDefault.setValue(key: "nightMode", value: true)
            
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
        if let messageID = userInfo[gcmMessageIDKey]
        {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)

        print("reset badge")
        Utilities.misc.resetBadge()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        if let messageID = userInfo[gcmMessageIDKey]
        {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        print("reset badge")
        Utilities.misc.resetBadge()
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
        Utilities.userDefault.setValue(key: "FCMToken", value: "Error")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        print("APNs token retrieved: token)")
        
        let token = Messaging.messaging().fcmToken
        
        if (token != nil)
        {
            print("Token Sending\n")
            Utilities.userDefault.setValue(key: "FCMToken", value: token ?? "")
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    {
        completionHandler(shouldPerformActionFor(shortcutItem: shortcutItem))
    }
    
    private func shouldPerformActionFor(shortcutItem: UIApplicationShortcutItem) -> Bool
    {
        guard let myNav = self.window?.rootViewController as? UINavigationController else
        {
            return false
        }
        
        guard let myTabBar = myNav.viewControllers.first as? MainTabBarViewController else
        {
            return false
        }

        myTabBar.selectedIndex = 2
        
        guard let nvc = myTabBar.selectedViewController as? UINavigationController else
        {
            return false
        }
        
        guard let vc = nvc.viewControllers.first as? SettingsTableViewController else
        {
            return false
        }
        
        vc.performSegue(withIdentifier: "showAddSound", sender: self)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Utilities.misc.resetBadge()
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate
{
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey]
        {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        print("reset badge")
        Utilities.misc.resetBadge()
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey]
        {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        print("reset badge")
        Utilities.misc.resetBadge()
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate
{
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String)
    {
        print("Firebase registration token: \(fcmToken)")
        Utilities.userDefault.setValue(key: "FCMToken", value: fcmToken)
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage)
    {
        print("Received data message: \(remoteMessage.appData)")
        
        print("reset badge")
        Utilities.misc.resetBadge()
    }
    // [END ios_10_data_message]
}
