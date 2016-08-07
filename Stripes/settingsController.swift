//  settingsView.swift
//  Stripes
//
//  Created by Koop Otten on 16/12/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation
import Crashlytics

class settingsController : UITableViewController, UIActionSheetDelegate {
//    let textCellIdentifier = "TextCell"
    var cell : UITableViewCell!
//    var generalInfoDic = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        
//        let editInfo = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "newGame")
//        navigationItem.rightBarButtonItem = editInfo
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "General info"
        case 1:
            return "Connect"
        default:
            return "Other"
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
        let label = UILabel()
        
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
        }

        switch indexPath.section {
        case 0:
            switch indexPath.row {
               case 0:
                cell!.textLabel?.text = "Username"
                label.text = PFUser.currentUser()!["fullName"] as? String
               case 1:
                cell!.textLabel?.text = "Email"
                label.text = PFUser.currentUser()!["email"] as? String
               case 2:
                cell!.textLabel?.text = "Games played"
                label.text = PFUser.currentUser()!["gamesPlayed"] != nil ? String(PFUser.currentUser()!["gamesPlayed"]) : String(0)
               default:
                ""
            }
        case 1:
            switch indexPath.row {
            case 0:
                if (PFUser.currentUser()!["fbId"] == nil) {
                    cell!.textLabel?.text = "Connect with Facebook"
                } else {
                    cell!.textLabel?.text = "You are already connected with Facebook!"
                }
            case 1:
                cell!.textLabel?.text = "Random game? Tap me to toggle."
                label.text = (PFUser.currentUser()!["lookingForGame"] as! Bool) ? "Yes" : "No" 
            default:
                ""
            }
        default:
            cell!.textLabel?.text = "Niks"
            
        }

        label.sizeToFit()
        cell!.accessoryView = label

        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                User.requestFaceBookLoggedInUserInfo()
            case 1:
                let value : Bool = PFUser.currentUser()!["lookingForGame"] as! Bool
                PFUser.currentUser()!.setObject(!value, forKey: "lookingForGame")
                
                PFUser.currentUser()!.saveInBackground()
                self.tableView.reloadData()
            default:
                ""
            }
            
        default:
            print("nee")
        }
    }
    
    func logOut() {
        let sheet : UIActionSheet = UIActionSheet()
        
        sheet.delegate = self
        sheet.addButtonWithTitle("Log Out")
        sheet.addButtonWithTitle("Cancel")
        sheet.cancelButtonIndex = 1
        
        sheet.showInView(self.view)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
        
//        print(cell?.accessoryView?.textInputMode.)
        
    }
    
//    func actionSheet(sheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
//        if buttonIndex == 0 {
//            PFUser.logOut()
//            
//            var loginController = LoginViewController()
//            self.navigationController?.pushViewController(loginController, animated: true)
//        }
//    }
}