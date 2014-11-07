//
//  AppDelegate.swift
//  Tiles-swift
//
//  Created by Koop Otten on 06/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navigationController : navController?
    var loginController : LoginViewController?
    var gamesOverviewController : GameOverviewController?
    var gameEngineController: GameEngineController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        loginController = LoginViewController()
        gameEngineController = GameEngineController()
        gamesOverviewController = GameOverviewController()
        navigationController = navController()
        
        Parse.setApplicationId("Rfb6FpX2ewMytcvOLIHjsZs2faNMSTMBMZCz3BUo", clientKey: "Dk5u1t8oQwTUNyOKDPSSMtjjAB74g3TGkw6EJWyR")
        PFFacebookUtils.initializeFacebook()
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        let notificationTypes:UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let notificationSettings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        
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
        
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        return true
    }
    
    func application(application: UIApplication!, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings!) {
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication!, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData!) {
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["gameNotification"]
        currentInstallation.saveInBackgroundWithBlock {
            (success: Bool!, error: NSError!) -> Void in
            println(success)
        }
        
        if (PFUser.currentUser() != nil) {
            currentInstallation["user"] = PFUser.currentUser()
        }
        
        currentInstallation.saveInBackgroundWithBlock {
            (success: Bool!, error: NSError!) -> Void in
            println(success)
        }
    }
    
    func application(application: UIApplication!, didFailToRegisterForRemoteNotificationsWithError error: NSError!) {
        println(error.localizedDescription)
    }
    
    func application(application: UIApplication!, didReceiveRemoteNotification userInfo:NSDictionary!) {
        
        var notification:NSDictionary = userInfo.objectForKey("aps") as NSDictionary
        
        if (notification.objectForKey("content-available") != nil) {
            if notification.objectForKey("content-available") as Int == 1 {
                NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
            }
        } else {
            PFPush.handlePush(userInfo)
        }
        
        
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: NSString?, annotation: AnyObject) -> Bool {
        
        //        var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        //        return wasHandled
        
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
        
        var currentInstallation = PFInstallation.currentInstallation()
        
        if (currentInstallation.badge != 0) {

            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
        
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
        println("hier")
        NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

