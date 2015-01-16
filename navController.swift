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
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
            
        } else {
            return UIInterfaceOrientationMask.LandscapeRight.rawValue.hashValue | UIInterfaceOrientationMask.LandscapeLeft.rawValue.hashValue
        }
    }
}