//
//  addNewGameController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 28/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class addNewGameController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var friendTableView : UITableView = UITableView()
    var cell : UITableViewCell?
    
    var allFriends : [AnyObject] = []
    
    
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
        var navBar = navigationController?.navigationBar
        self.friendTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(friendTableView)
        
        
        friendTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        friendTableView.constrainToSize(CGSizeMake(400, 400))
        friendTableView.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: self.view)
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
      
        cell!.textLabel.text = String(user.name as NSString)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = friendTableView.cellForRowAtIndexPath(indexPath)
        var opponentName = cell?.textLabel.text
        
        var gameObjectId = Game.addGame("\(opponentName!)", grid: 5)
        
        self.presentViewController(GameOverviewController(), animated: true, completion: nil)
    }
    
    func addNavigationItems() {
       navigationItem.title = "New Game" 
    }
}










