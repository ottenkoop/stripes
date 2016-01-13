
//  addNewGameController.swift
//  SWIFT
//
//  Created by Koop Otten on 28/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class addNewGameController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate  {
    let searchController = UISearchController(searchResultsController: nil)
    
    var cell : UITableViewCell!
    var searchBar : UISearchBar = UISearchBar()
    
    var allFriends : [AnyObject] = []
    var showFaceBookFriends : Bool = false

    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    var opponentName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "gameBackground")!)
        
        SVProgressHUD.show()
        
        addNavigationItems()
        addTableView()
        loadTableViewContent()
    }
    
    func addTableView() {
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Default
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
    }

    func addSearchBar() {
        searchController.searchBar.delegate = self
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
                        if task.error == nil {
                            self.allFriends = task.result! as! [AnyObject]
                            self.tableView.reloadData()
                        }
                        
                        return task
                    }
                    
                    1.0.waitSecondsAndDo({
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                    })
                    
                } else {
                    self.addSearchBar()
                    self.showFaceBookFriends = false
                    SVProgressHUD.dismiss()
                }
            }
        } else {
//             show search btn
            addSearchBar()
            SVProgressHUD.dismiss()
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = allFriends.count as Int
        
        if count > 0 {
            return count
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
        
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
        }
        
        let user : PFUser = allFriends[Int(indexPath.row)] as! PFUser
        cell!.textLabel?.text = user["fullName"] as? String
    
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        SVProgressHUD.show()

        let opponent : PFUser = allFriends[Int(indexPath.row)] as! PFUser
        let battleExists = checkIfBattleExists(opponent)
//        let battleExists = false
        
        if battleExists {
            let alert = UIAlertView(title: "Uh oh!", message: "This battle already exists.", delegate: self, cancelButtonTitle: "Return")
            alert.show()
            SVProgressHUD.dismiss()
        } else {
            Game.addGame(opponent, grid: 3)
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text?.characters.count > 1 {
            let userQuery = searchModule.findUsers(searchController.searchBar.text!)

            userQuery.findObjectsInBackground().continueWithBlock {
                (task: BFTask!) -> AnyObject in
                if task.error == nil {
                    self.allFriends.removeAll(keepCapacity: false)
                    self.allFriends = task.result as! [AnyObject]

                }
                
                return task
            }
            
            self.tableView.reloadData()
        }
        else {
            allFriends.removeAll(keepCapacity: false)
            self.tableView.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.tableView.reloadData()
        
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
        navigationItem.title = showFaceBookFriends ? "Facebook friends" : "Find player"
        navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
    }
}