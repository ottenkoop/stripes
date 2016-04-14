
//  settingsView.swift
//  Stripes
//
//  Created by Koop Otten on 16/12/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class settingsController : UITableViewController, UIActionSheetDelegate {
//    let textCellIdentifier = "TextCell"
    var cell : UITableViewCell!
    var generalInfoDic = [String:String]()
    var otherInfoDic = [String:String]()
//    var generalInfoDic = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        fillGeneralInfo()
    }
    
    func fillGeneralInfo() {
        generalInfoDic["Logged in as"] = PFUser.currentUser()!["fullName"] as? String
        generalInfoDic["Version number"] = PFInstallation.currentInstallation()["appVersion"] as? String
        generalInfoDic["Special user"] = "OFCOURSE!"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return generalInfoDic.count
        case 1:
            return 0
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
            return "Other shit"
        default:
            return "IDK"
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
            let key = Array(generalInfoDic.keys)[indexPath.row]
            
            cell!.textLabel?.text = key
            label.text = generalInfoDic[key]!

        case 1:
            cell!.textLabel?.text = "Egeltje"
        default:
            cell!.textLabel?.text = "Niks"
            
        }

        label.sizeToFit()
        cell!.accessoryView = label

        
        return cell!
    }
    
    func logOut() {
        let sheet : UIActionSheet = UIActionSheet()
        
        sheet.delegate = self
        sheet.addButtonWithTitle("Log Out")
        sheet.addButtonWithTitle("Cancel")
        sheet.cancelButtonIndex = 1
        
        sheet.showInView(self.view)
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