//
//  navController.swift
//  Stripes
//
//  Created by Koop Otten on 06/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class navController: UINavigationController {
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.Portrait
            
        } else {
            return UIInterfaceOrientationMask.LandscapeRight.rawValue.hashValue | UIInterfaceOrientationMask.LandscapeLeft.rawValue.hashValue as! UIInterfaceOrientationMask
        }
    }
}