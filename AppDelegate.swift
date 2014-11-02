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
    var navController : UINavigationController?
    var loginController : LoginViewController?
    var gameEngineController: GameEngineController?
    var gamesOverviewController : GameOverviewController?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        loginController = LoginViewController()
        gameEngineController = GameEngineController()
        gamesOverviewController = GameOverviewController()
        navController = UINavigationController()
        
        Parse.setApplicationId("Rfb6FpX2ewMytcvOLIHjsZs2faNMSTMBMZCz3BUo", clientKey: "Dk5u1t8oQwTUNyOKDPSSMtjjAB74g3TGkw6EJWyR")
        PFFacebookUtils.initializeFacebook()
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        window = UIWindow (frame: UIScreen.mainScreen().bounds)
        
        if (PFUser.currentUser() != nil) {
            self.navController?.pushViewController(GameOverviewController(), animated: false)
            window!.rootViewController = navController!
        } else {
            window!.rootViewController = loginController!
        }
        
//        window!.rootViewController = gameEngineController!
        
        window!.makeKeyAndVisible()
        
        FBLoginView.self
        FBProfilePictureView.self
        
        return true
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
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

