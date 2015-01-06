//
//  settingsView.swift
//  Stripes
//
//  Created by Koop Otten on 16/12/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class settingsView : QuickDialogController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.root = QRootElement()
        self.root.grouped = true
        
        var infoSection = QSection(title: "Info")
        
        var version = QLabelElement(title: "Version", value: PFInstallation.currentInstallation()["appVersion"])
        var logOut = QLabelElement()
        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
            logOut = QLabelElement(title: "Logged in as:", value: PFUser.currentUser()["fullName"])
        } else {
            logOut = QLabelElement(title: "Logged in as:", value: PFUser.currentUser()["username"])
        }
        
        logOut.controllerAction = "logOut"
        infoSection.addElement(version)
        infoSection.addElement(logOut)
        
        self.root.addSection(infoSection)
    }
    
    func logOut() {
        var sheet : UIActionSheet = UIActionSheet()
        
        sheet.addButtonWithTitle("Log Out")
        sheet.addButtonWithTitle("Cancel")
        sheet.cancelButtonIndex = 1
        
        sheet.showInView(self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}