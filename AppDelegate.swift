 //
//  AppDelegate.swift
//  Tiles-swift
//
//  Created by Koop Otten on 06/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navigationController : navController?
    var loginController : LoginViewController?
    var gamesOverviewController : GameOverviewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        loginController = LoginViewController()
        gamesOverviewController = GameOverviewController()
        navigationController = navController()
        
        ParseCrashReporting.enable()
        Parse.enableLocalDatastore()
        Parse.setApplicationId("Rfb6FpX2ewMytcvOLIHjsZs2faNMSTMBMZCz3BUo", clientKey: "Dk5u1t8oQwTUNyOKDPSSMtjjAB74g3TGkw6EJWyR")
        
        PFFacebookUtils.initializeFacebook()
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
//
//        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("0ca020e3c03e6f1f569fd4201ad5a1be")
//        BITHockeyManager.sharedHockeyManager().startManager()
//        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
//        BITHockeyManager.sharedHockeyManager().testIdentifier()
        
        registerForRemoteNotification()
        
        window = UIWindow (frame: UIScreen.mainScreen().bounds)

        window!.rootViewController = navigationController!
        
        if (PFUser.currentUser() != nil) {
            self.navigationController?.pushViewController(gamesOverviewController!, animated: false)
        } else {
            self.navigationController?.pushViewController(loginController!, animated: false)
        }
        
        window!.makeKeyAndVisible()
        
        FBLoginView.self
        FBProfilePictureView.self
        
        return true
    }
    
    func registerForRemoteNotification() {
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            let notificationTypes : UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
            
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert)
        }
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation : PFInstallation = PFInstallation.currentInstallation()
        
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["gameNotification"]
        
        if (PFUser.currentUser() != nil) {
            currentInstallation["user"] = PFUser.currentUser()
        }
        
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println(error.localizedDescription)
    }

    //    func application(application: UIApplication,
//        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
//        fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//            if let photoId: String = userInfo["p"] as? String {
//                let targetPhoto = PFObject(withoutDataWithClassName: "Photo", objectId: photoId)
//                targetPhoto.fetchIfNeededInBackgroundWithBlock({ (object: PFObject!, error: NSError!) -> Void in
//                    // Show photo view controller
//                    if error != nil {
//                        completionHandler(UIBackgroundFetchResult.Failed)
//                    } else if PFUser.currentUser() != nil {
//                        let viewController = PhotoVC(withPhoto: object)
//                        self.navController.pushViewController(viewController, animated: true)
//                        completionHandler(UIBackgroundFetchResult.NewData)
//                    } else {
//                        completionHandler(UIBackgroundFetchResult.NoData)
//                    }
//                })
//            }
//            handler(UIBackgroundFetchResult.NoData)
//    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        var notification:NSDictionary = userInfo["aps"] as! NSDictionary
        
        if (notification.objectForKey("content-available") != nil) {
            if notification.objectForKey("content-available") as! Int == 1 {
                NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
                //                NSNotificationCenter.defaultCenter().postNotificationName("resetLookingForGame", object: nil)
            }
        } else {
            PFPush.handlePush(userInfo)
        }

    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, withSession:PFFacebookUtils.session())
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your applicationports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
        NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

