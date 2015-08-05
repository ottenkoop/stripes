//
//  settingsView.swift
//  Stripes
//
//  Created by Koop Otten on 16/12/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class settingsView : UITableViewController, UIActionSheetDelegate {

    private var settingsTable : UITableView = UITableView()
    let textCellIdentifier = "TextCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

//        self.root = QRootElement()
//        self.root.grouped = true
        
//        var infoSection = QSection(title: "Info")
        
//        var version = QLabelElement(title: "Version", value: PFInstallation.currentInstallation()["appVersion"])
//        var logOut = QLabelElement()
        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
//            logOut = QLabelElement(title: "Logged in as!:", value: PFUser.currentUser()["fullName"])
        } else {
//            logOut = QLabelElement(title: "Logged in as!:", value: PFUser.currentUser()["username"])
        }
        
//        logOut.controllerAction = "logOut"
//        infoSection.addElement(version)
//        infoSection.addElement(logOut)
        
//        self.root.addSection(infoSection)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = "HOndje"
        
        return cell
    }
    
    func logOut() {
        var sheet : UIActionSheet = UIActionSheet()
        
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