
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
    
    var opponent : PFUser = PFUser()
    
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
    
    func reloadGameTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
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
                        if task.error == nil {
                            self.allFriends = task.result! as! [AnyObject]
                            self.reloadGameTableView()
                        }
                        
                        return task
                    }
                    
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
        
        if allFriends.count > 0 {
            let user : PFUser = allFriends[Int(indexPath.row)] as! PFUser
            cell!.textLabel?.text = user["fullName"] as? String
        }
    
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let gameOptionBtns = newGameTypeOptionsPopup().openPopup(self.view)
        opponent = allFriends[Int(indexPath.row)] as! PFUser
        
        gameOptionBtns[0].addTarget(self, action: #selector(addNewGameController.normalGame(_:)), forControlEvents: .TouchUpInside)
        gameOptionBtns[1].addTarget(self, action: #selector(addNewGameController.gameWithSpecials(_:)), forControlEvents: .TouchUpInside)
        gameOptionBtns[2].addTarget(self, action: #selector(addNewGameController.cancelBtnPressed(_:)), forControlEvents: .TouchUpInside)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text?.characters.count > 1 {
            SVProgressHUD.show()
            self.allFriends.removeAll(keepCapacity: false)
            self.tableView.reloadData()
            
            let userQuery = searchModule.findUsers(searchController.searchBar.text!)
            userQuery.findObjectsInBackground().continueWithBlock {
                (task: BFTask!) -> AnyObject in
                if task.error == nil {
                    self.allFriends = task.result as! [AnyObject]
                    self.reloadGameTableView()
                }
                
                return task
            }
        }
        else {
            allFriends.removeAll(keepCapacity: false)
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
    func normalGame(button : UIButton!) {
        newGame(false)
    }
    
    func gameWithSpecials(button : UIButton!) {
        newGame(true)
    }
    
    func cancelBtnPressed(cButton : UIButton!) {
        newGameTypeOptionsPopup().hidePopup(cButton)
        opponent = PFUser()
        
        navigationItem.leftBarButtonItem?.enabled = true
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func newGame(withSpecials:Bool) {
        Game.addGame(opponent, gameWithSpecials: withSpecials, grid: 3)
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func addNavigationItems() {
        navigationItem.title = showFaceBookFriends ? "Facebook friends" : "Find player"
        navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
    }
}