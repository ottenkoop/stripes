//
//  finishScreen.swift
//  Stripes
//
//  Created by Koop Otten on 10/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation
import UIKit

class finishScreen {
    
    var container: UIView = UIView()
    var textView: UILabel = UILabel()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    /*
    Show customized activity indicator,
    actually add activity indicator to passing view
    
    @param uiView - add activity indicator to this view
    */
    func gameDidFinishWithCurrentUserWinner(uiView: UIView) -> UIView {
        defaultContainerSetup(uiView)
        
        textView.text = "Joepie! Je hebt gewonnen"
        
        return container
    }
    
    func gameDidFinishWithOpponentWinner(uiView: UIView) -> UIView {
        
        
        
        return container
    }
    
    func defaultContainerSetup(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor.colorWithRGBHexWithAlpha(0x5AB103, alpha: 1.0)
        
        textView.frame = CGRectMake(0, 0, container.bounds.width, 100)
        textView.center = uiView.center
        textView.textAlignment = .Center

        uiView.addSubview(container)
        container.addSubview(textView)
    }
    
    /*
    Hide activity indicator
    Actually remove activity indicator from its super view
    
    @param uiView - remove activity indicator from this view
    */
    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}