//
//  addNewGameController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 28/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class addNewGameController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    var friendTableView : UITableView = UITableView()
    var cell : UITableViewCell?
    
    var allFriends : [AnyObject] = []
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    var opponentName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        friendTableView.delegate = self
        friendTableView.dataSource = self
        
        addTableView()
        loadTableViewContent()
        addNavigationItems()
    }
    
    func addTableView() {
        self.friendTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(friendTableView)
        
        friendTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        friendTableView.constrainToSize(CGSizeMake(screenWidth, screenHeight))
        friendTableView.pinAttribute(.Top, toAttribute: .Top, ofItem: self.view)
        friendTableView.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view)
    }
    
    func loadTableViewContent () {
        var friendsRequest : FBRequest = FBRequest.requestForMyFriends()
        
        friendsRequest.startWithCompletionHandler {
            (connection : FBRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                var resultdict = result as NSDictionary
                self.allFriends = resultdict.objectForKey("data") as NSArray
                
                self.friendTableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = allFriends.count as Int
        
        if count > 0 {
            return count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = friendTableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        let user : AnyObject = allFriends[Int(indexPath.row)]
      
        cell!.textLabel?.text = String(user.name as NSString)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = friendTableView.cellForRowAtIndexPath(indexPath)
        var oppName = cell!.textLabel?.text
        
        opponentName = oppName!
        
        var sheet : UIActionSheet = UIActionSheet()
        let title = "Select a grid"
        
        sheet.title = title
        sheet.delegate = self
        sheet.addButtonWithTitle("3x3")
        sheet.addButtonWithTitle("4x4")
        sheet.addButtonWithTitle("Cancel")
        sheet.cancelButtonIndex = 2

        sheet.showInView(self.view)
    }
    
    func actionSheet(sheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            Game.addGame("\(opponentName)", grid: 3)
            self.navigationController!.popViewControllerAnimated(true)
        } else if buttonIndex == 1 {
            Game.addGame("\(opponentName)", grid: 4)
            self.navigationController!.popViewControllerAnimated(true)
        } else {
            sheet.dismissWithClickedButtonIndex(2, animated: true)
        }
    }
    
    func addNavigationItems() {
       navigationItem.title = "New Game" 
    }
}










