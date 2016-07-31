 //
//  AppDelegate.swift
//  Tiles-swift
//
//  Created by Koop Otten on 06/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
//import ParseClient

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
        
        Parse.enableLocalDatastore()
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "Rfb6FpX2ewMytcvOLIHjsZs2faNMSTMBMZCz3BUo"
            $0.clientKey = "Dk5u1t8oQwTUNyOKDPSSMtjjAB74g3TGkw6EJWyR"
            $0.server = "https://parseapi.back4app.com"
        }
        
        Parse.initializeWithConfiguration(configuration)
        
        PFFacebookUtils.initializeFacebook()
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        Fabric.with([Crashlytics.self])

        registerForRemoteNotification()
        checkIfUserNeedsFetching()
        
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
        let notificationTypes : UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    func checkIfUserNeedsFetching() {
        if (PFUser.currentUser() != nil) && (PFUser.currentUser()!.dataAvailable) {
            User.fetchUserInfoInBackground()
        }
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation : PFInstallation = PFInstallation.currentInstallation()
        
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["gameNotification", "testing", "Iamawesome"]
        
        if (PFUser.currentUser() != nil) {
            currentInstallation["user"] = PFUser.currentUser()
        }
        
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error.localizedDescription)
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
        
        let notification:NSDictionary = userInfo["aps"] as! NSDictionary

        if (notification.objectForKey("random-game") != nil) {
            if notification.objectForKey("random-game") as! Bool {
                NSNotificationCenter.defaultCenter().postNotificationName("resetLookingForGame", object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
            }
        } else {
            PFPush.handlePush(userInfo)
            NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
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
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

