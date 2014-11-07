//
//  LoginController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 06/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIAlertViewDelegate {
    
    private var fbLoginView = UIButton.buttonWithType(UIButtonType.System) as UIButton
    private var logoView = UIImageView(image: UIImage(named: "logo"))
    private var registerBtn = UIButton.buttonWithType(UIButtonType.System) as UIButton

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        addLogoView()
        addFacebookLogin()
        addRegisterBtn()
        
        navigationController!.navigationBarHidden = true
    }
    
    func addLogoView () {
        self.view.addSubview(logoView)
        
        logoView.setTranslatesAutoresizingMaskIntoConstraints(false)
        logoView.constrainToSize(CGSizeMake(150, 200))
        logoView.centerInContainerOnAxis(NSLayoutAttribute.CenterX)
        logoView.pinAttribute(.Top, toAttribute: .Top, ofItem: self.view, withConstant: 50)
    }
    
    func addFacebookLogin () {
        fbLoginView.addTarget(self, action: "fbButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        fbLoginView.setTitle("Facebook", forState: .Normal)
        self.view.addSubview(fbLoginView)

        fbLoginView.setTranslatesAutoresizingMaskIntoConstraints(false)
        fbLoginView.centerInContainerOnAxis(NSLayoutAttribute.CenterX)
        fbLoginView.pinAttribute(NSLayoutAttribute.Bottom, toAttribute: NSLayoutAttribute.Bottom, ofItem: logoView, withConstant: 150)
        fbLoginView.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        fbLoginView.constrainToSize(CGSizeMake(218, 50))
        fbLoginView.layer.borderColor = UIColor.blueColor().CGColor
        fbLoginView.layer.borderWidth = 2
        fbLoginView.layer.cornerRadius = 23
        
    }
    
    func addRegisterBtn () {
        registerBtn.setTitle("Register", forState: UIControlState.Normal)
        registerBtn.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(registerBtn)
        
        addStyleAndPositionToRegisterBtn()
    }
    
    func addStyleAndPositionToRegisterBtn () {
        registerBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        registerBtn.backgroundColor = UIColor.grayColor()
        registerBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        registerBtn.constrainToSize(CGSizeMake(218, 50))
        registerBtn.layer.cornerRadius = 2
        registerBtn.centerInContainerOnAxis(NSLayoutAttribute.CenterX)
        registerBtn.pinAttribute(NSLayoutAttribute.Bottom, toAttribute: NSLayoutAttribute.Bottom, ofItem: fbLoginView, withConstant: 75)
    }
    
    func buttonAction(sender:UIButton!){
        println("HENK tapped")
    }

//--FacebookLogin Handlers
    
    func fbButtonAction(sender: UIButton!) {
        var permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInWithPermissions(permissions, {
            (user: PFUser!, error: NSError!) -> Void in
            
            if user == nil {
                let alert = UIAlertView(title: "Facebook login failed", message: "Please check your Facebook settings on your phone.", delegate: self, cancelButtonTitle: "Ok")
                alert.show()
            } else if user.isNew {
                NSLog("User signed up and logged in through Facebook!")
                User.requestFaceBookLoggedInUserInfo()
                self.openGameOverviewController()
            } else {
                NSLog("User logged in through Facebook!")
                self.openGameOverviewController()
            }
        })
    }
    
    func openGameOverviewController() {
        navigationController!.pushViewController(GameOverviewController(), animated: true)
        
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation["user"] = PFUser.currentUser()
        currentInstallation.saveInBackgroundWithTarget(nil, selector: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
}
