//
//  loadingView.swift
//  Stripes
//
//  Created by Koop Otten on 05/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation
import UIKit

class loadingView {
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func showActivityIndicator(uiView: UIView) -> UIView {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor.colorWithRGBHexWithAlpha(0x444444, alpha: 0.2)
        
        SVProgressHUD.show()
        uiView.addSubview(container)
        
        return container
    }
    
    func hideActivityIndicatorWhenReturning(uiView: UIView) {
        SVProgressHUD.dismiss()
        uiView.removeFromSuperview()
    }
    
    func hideActivityIndicatorWhenScoring(uiView: UIView, points : Int) {
        SVProgressHUD.setFont(UIFont(name: "", size: 28))
        SVProgressHUD.showSuccessWithStatus("+\(points)")
        uiView.removeFromSuperview()
    }
}