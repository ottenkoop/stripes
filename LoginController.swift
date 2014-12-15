//
//  LoginController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 06/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIAlertViewDelegate {
    
    private var fbLoginView = UIButton()
    private var logoView = UIImageView(image: UIImage(named: "logo"))
    private var loginBtn = UIButton()
    private var registerBtn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        addLogoView()
        addFacebookLogin()
        addLoginBtn()
        addRegisterBtn()
        
        navigationController!.navigationBarHidden = true
    }
    
    func addLogoView () {
        self.view.addSubview(logoView)
        
        logoView.setTranslatesAutoresizingMaskIntoConstraints(false)
        logoView.constrainToSize(CGSizeMake(175, 225))
        logoView.centerInContainerOnAxis(NSLayoutAttribute.CenterX)
        logoView.pinAttribute(.Top, toAttribute: .Top, ofItem: self.view, withConstant: 40)
    }
    
    func addFacebookLogin () {
        self.view.addSubview(fbLoginView)

        fbLoginView.addTarget(self, action: "fbButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        fbLoginView.setTranslatesAutoresizingMaskIntoConstraints(false)
        fbLoginView.centerInContainerOnAxis(NSLayoutAttribute.CenterX)
        fbLoginView.setImage(UIImage(named: "faceBookLogin"), forState: .Normal)
        fbLoginView.pinAttribute(NSLayoutAttribute.Bottom, toAttribute: NSLayoutAttribute.Bottom, ofItem: logoView, withConstant: 75)
        fbLoginView.constrainToSize(CGSizeMake(280, 50))
    }
    
    func addLoginBtn() {
        self.view.addSubview(loginBtn)
        
        loginBtn.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        loginBtn.setImage(UIImage(named: "loginButton"), forState: .Normal)
        loginBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        loginBtn.constrainToSize(CGSizeMake(280, 50))
        loginBtn.centerInContainerOnAxis(.CenterX)
        loginBtn.pinAttribute(NSLayoutAttribute.Bottom, toAttribute: NSLayoutAttribute.Bottom, ofItem: fbLoginView, withConstant: 75)
    }
    
    func addRegisterBtn() {
        self.view.addSubview(registerBtn)
        
        registerBtn.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        registerBtn.setImage(UIImage(named: "registerButton"), forState: .Normal)
        registerBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        registerBtn.constrainToSize(CGSizeMake(280, 50))
        registerBtn.centerInContainerOnAxis(.CenterX)
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
                User.requestFaceBookLoggedInUserInfo()
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
