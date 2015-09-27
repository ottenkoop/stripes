//
//  addNewGameController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 28/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class addNewGameController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    var friendTableView : UITableView = UITableView()
    var cell : UITableViewCell!
    var searchBar : UISearchBar = UISearchBar()
    var searchController : UISearchDisplayController!
    
    var allFriends : [AnyObject] = []
    var showFaceBookFriends : Bool = false
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    var opponentName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendTableView.backgroundColor = UIColor(patternImage: UIImage(named: "gameBackground")!)
        
        friendTableView.delegate = self
        friendTableView.dataSource = self
        
        SVProgressHUD.show()
        addTableView()
        loadTableViewContent()
        addNavigationItems()
    }
    
    func addTableView() {
        self.friendTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(friendTableView)
        
        friendTableView.translatesAutoresizingMaskIntoConstraints = false
        friendTableView.constrainToHeight(screenHeight)
        friendTableView.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view)
        friendTableView.pinAttribute(.Right, toAttribute: .Right, ofItem: self.view)
        friendTableView.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: self.view)
    }
    
    func addSearchBar() {
        SVProgressHUD.dismiss()
        
        searchBar.backgroundColor = UIColor.whiteColor()
        searchBar.delegate = self
        searchBar.sizeToFit()
        
        friendTableView.tableHeaderView = searchBar
        
        searchController = UISearchDisplayController(searchBar: searchBar, contentsController: self)
        searchController.searchResultsDataSource = self
        searchController.searchResultsDelegate = self
        searchController.searchResultsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let userQuery = searchModule.findUsers(searchBar.text!)
        
        userQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.allFriends = objects!
                
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }
        }
    }
    
    func loadTableViewContent() {
        if showFaceBookFriends {
            let friendsRequest : FBRequest = FBRequest.requestForMyFriends()
            
            friendsRequest.startWithCompletionHandler {
                (connection : FBRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                
                if error == nil {
                    let friendObjects : NSArray = result.objectForKey("data") as! NSArray
                    let friendIds : NSMutableArray = NSMutableArray(capacity: friendObjects.count)
                    
                    for friendObject in friendObjects as! [NSDictionary] {
                        friendIds.addObject(friendObject.objectForKey("id")!)
                    }
                    
                    let friendQuery : PFQuery = PFUser.query()!
                    friendQuery.whereKey("fbId", containedIn: friendIds as [AnyObject])
                    
                    friendQuery.findObjectsInBackground().continueWithBlock {
                        (task: BFTask!) -> AnyObject in
                        
                        self.allFriends = task.result! as! [AnyObject]
                        self.friendTableView.reloadData()
                        SVProgressHUD.dismiss()
                        
                        return task
                    }
                } else {
                    self.addSearchBar()
                    self.showFaceBookFriends = false
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            // show search btn
            addSearchBar()
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
        var cell = friendTableView.dequeueReusableCellWithIdentifier("cell")
        
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
        }
        
        let user : PFUser = allFriends[Int(indexPath.row)] as! PFUser
        cell!.textLabel?.text = user["fullName"] as? String
    
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        SVProgressHUD.show()

        let opponent : PFUser = allFriends[Int(indexPath.row)] as! PFUser
        let battleExists = checkIfBattleExists(opponent)
        
        if battleExists {
            let alert = UIAlertView(title: "Uh oh!", message: "This battle already exists.", delegate: self, cancelButtonTitle: "Return")
            alert.show()
            SVProgressHUD.dismiss()
        } else {
            Game.addGame(opponent, grid: 3)
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    func checkIfBattleExists(opp: PFUser) -> Bool {
        var weekBattle : [AnyObject] = []
        let predicate = NSPredicate(format: "user = %@ AND user2 = %@ OR user2 = %@ AND user = %@", PFUser.currentUser()!, opp, PFUser.currentUser()!, opp)
        
        let weekBattleQuery = PFQuery(className:"weekBattle", predicate: predicate)
        
        weekBattleQuery.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject in
            
            weekBattle = task.result as! [AnyObject]
            return task
        }
        
        if weekBattle.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func addNavigationItems() {
        navigationItem.title = "New Game"
        navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
    }
}