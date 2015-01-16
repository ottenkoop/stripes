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
    var cell : UITableViewCell?
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
        
        friendTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        friendTableView.constrainToSize(CGSizeMake(screenWidth, screenHeight))
        friendTableView.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view)
    }
    
    func addSearchBar() {
        SVProgressHUD.dismiss()
        
//        searchBar.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        var userQuery = searchModule.findUsers(searchBar.text)
        
        userQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                println(objects)
                self.allFriends = objects
                
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }
        })
    }
    
    func loadTableViewContent () {
        if showFaceBookFriends {
            var friendsRequest : FBRequest = FBRequest.requestForMyFriends()
            
            friendsRequest.startWithCompletionHandler {
                (connection : FBRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                
                if error == nil {
                    var resultdict = result as NSDictionary
                    self.allFriends = resultdict.objectForKey("data") as NSArray
                    
                    self.friendTableView.reloadData()
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
        var cell = friendTableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
        }
        
        if showFaceBookFriends {
            var user : AnyObject = allFriends[Int(indexPath.row)]
            cell!.textLabel?.text = String(user.name as NSString)
        } else {
            var user : AnyObject = allFriends[Int(indexPath.row)]
            cell!.textLabel?.text = String(user["fullName"] as NSString)
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if showFaceBookFriends {
            cell = friendTableView.cellForRowAtIndexPath(indexPath)
        } else {
            cell = searchDisplayController?.searchResultsTableView.cellForRowAtIndexPath(indexPath)
        }

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
        SVProgressHUD.show()
        if buttonIndex == 0 {
            var battleExists = checkIfBattleExists(opponentName)
            
            if battleExists {
                let alert = UIAlertView(title: "Uh oh!", message: "This battle already exists.", delegate: self, cancelButtonTitle: "Return")
                alert.show()
                SVProgressHUD.dismiss()
            } else {
                Game.addGame("\(opponentName)", grid: 3)
                self.navigationController!.popViewControllerAnimated(true)
            }
            
        } else if buttonIndex == 1 {
            Game.addGame("\(opponentName)", grid: 4)
            self.navigationController!.popViewControllerAnimated(true)
        } else {
            sheet.dismissWithClickedButtonIndex(2, animated: true)
            SVProgressHUD.dismiss()
        }
    }
    
    func checkIfBattleExists(oppName: NSString) -> Bool {
        var query = PFQuery(className:"weekBattle")
        
        println(oppName)
        
        let predicate = NSPredicate(format: "userFullName = %@ AND user2FullName = %@ OR user2FullName = %@ AND user2FullName = %@", PFUser.currentUser()["fullName"] as NSString, oppName, PFUser.currentUser()["fullName"] as NSString, oppName)
        
        var weekBattle = query.findObjects()
        
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










