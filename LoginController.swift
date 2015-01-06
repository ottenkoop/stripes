//
//  LoginController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 06/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIAlertViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
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
        fbLoginView.setImage(UIImage(named: "faceBookLogin"), forState: .Normal)
        fbLoginView.setTranslatesAutoresizingMaskIntoConstraints(false)
        fbLoginView.constrainToSize(CGSizeMake(280, 50))
        fbLoginView.centerInContainerOnAxis(.CenterX)
        fbLoginView.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: logoView, withConstant: 75)
    }
    
    func addLoginBtn() {
        self.view.addSubview(loginBtn)
        
        loginBtn.addTarget(self, action: "loginButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        loginBtn.setImage(UIImage(named: "stripesLoginButton"), forState: .Normal)
        loginBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        loginBtn.constrainToSize(CGSizeMake(280, 50))
        loginBtn.centerInContainerOnAxis(.CenterX)
        loginBtn.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: fbLoginView, withConstant: 75)
    }
    
    func addRegisterBtn() {
        self.view.addSubview(registerBtn)
        
        registerBtn.setImage(UIImage(named: "registerButton"), forState: .Normal)
        registerBtn.addTarget(self, action: "registerButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        registerBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        registerBtn.centerInContainerOnAxis(.CenterX)
        registerBtn.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: self.view, withConstant: -10)
        registerBtn.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view, withConstant: 10)
        registerBtn.pinAttribute(.Right, toAttribute: .Right, ofItem: self.view, withConstant: -10)
    }
    
    func loginButtonTapped(sender:UIButton!) {
        var logInController = PFLogInViewController()
        logInController.delegate = self
        logInController.fields = PFLogInFields.DismissButton | PFLogInFields.UsernameAndPassword | PFLogInFields.PasswordForgotten | PFLogInFields.LogInButton
        logInController.logInView.logo = nil
        
        styleLoginAndSignupField(logInController.logInView.logInButton, image: "loginBtn")

        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            logInController.logInView.logInButton.pinAttribute(.Top, toAttribute: .Bottom, ofItem: logInController.logInView.passwordField, withConstant: 10)
        }
        
        self.presentViewController(logInController, animated:true, completion: nil)
    }
    
    func registerButtonTapped(sender:UIButton!) {
        var signupController = PFSignUpViewController()
        signupController.delegate = self
        signupController.fields = PFSignUpFields.DismissButton | PFSignUpFields.UsernameAndPassword | PFSignUpFields.Email | PFSignUpFields.SignUpButton
        signupController.signUpView.logo = nil

        styleLoginAndSignupField(signupController.signUpView.signUpButton, image: "registerButton")
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            signupController.signUpView.signUpButton.pinAttribute(.Top, toAttribute: .Bottom, ofItem: signupController.signUpView.emailField, withConstant: 10)
        }

        self.presentViewController(signupController, animated:true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        loadingView().showActivityIndicator(self.view)
        openGameOverviewController()
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        loadingView().showActivityIndicator(self.view)
        User.updateUserFullName()
        openGameOverviewController()
    }
    
    func styleLoginAndSignupField(button : UIButton, image : NSString) {
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle("", forState: .Normal)
        button.centerInContainerOnAxis(.CenterX)
        button.constrainToWidth(280)
        button.setBackgroundImage(UIImage(named: "\(image)"), forState: .Normal)
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
        self.navigationController!.pushViewController(GameOverviewController(), animated: true)
        self.navigationController!.navigationBarHidden = false
        
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
