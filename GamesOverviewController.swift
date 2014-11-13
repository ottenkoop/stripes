//
//  GamesOverviewController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 16/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class GameOverviewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var gameTableView : UITableView = UITableView()
    var cell : UITableViewCell?
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    var gamesWithUserTurn : [PFObject] = []
    var gamesWithOpponentTurn : [PFObject] = []
    var currentGameIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBarHidden = false
//        self.gameTableView.backgroundColor = UIColor(patternImage: UIImage(named: "gameScreenBackground")!)
        
        gameTableView.delegate = self
        gameTableView.dataSource = self

        addRefreshTableDrag()
        addTableView()
        loadTableViewContent()
        addNavigationItems()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadTableViewContent", name: "reloadGameTableView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteObjectFromSection", name: "deleteObjectFromYourTurnSection", object: nil)
    }
    
    func deleteObjectFromSection() {

        println(currentGameIndex)
        
        var game : PFObject = gamesWithUserTurn[currentGameIndex] as PFObject
        
        gamesWithUserTurn.removeAtIndex(currentGameIndex)
        gamesWithOpponentTurn += [game]
    }
    
    func addNewGameBtn() {
        let newGameBtn = UIButton ()
        var navBar = navigationController?.navigationBar
        
        newGameBtn.backgroundColor = UIColor.colorWithRGBHex(0x5AB103)
        newGameBtn.setTitle("New Game", forState: .Normal)
        newGameBtn.addTarget(self, action: "newGame", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(newGameBtn)
        newGameBtn.setTranslatesAutoresizingMaskIntoConstraints(false)

        newGameBtn.pinAttribute(.Top, toAttribute: .Bottom, ofItem: navBar, withConstant: 0)
    }
    
    func addRefreshTableDrag () {
        var refreshControl = UIRefreshControl()
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        gameTableView.addSubview(refreshControl)
    }
    
    func refresh (sender: UIRefreshControl) {
        loadTableViewContent()
        
        sender.endRefreshing()
    }
    
    func addTableView() {
        self.gameTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(gameTableView)
        
        gameTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        gameTableView.constrainToSize(CGSizeMake(screenWidth, screenHeight))
        gameTableView.pinAttribute(.Top, toAttribute: .Top, ofItem: self.view)
        gameTableView.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: self.view)
        gameTableView.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Int(gamesWithUserTurn.count)
        case 1:
            return Int(gamesWithOpponentTurn.count)
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        switch section {
        case 0:
            return "Your Turn"
        case 1:
            return "Their Turn"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = gameTableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        switch indexPath.section {
        case 0:
            let gameUserTurn = gamesWithUserTurn[Int(indexPath.row)] as PFObject
            var attributedText = NSMutableAttributedString()
            
            if gameUserTurn["user"].objectId == PFUser.currentUser().objectId {
                attributedText = NSMutableAttributedString(string: String(gameUserTurn["user2FullName"] as NSString))
            } else {
                attributedText = NSMutableAttributedString(string: String(gameUserTurn["userFullName"] as NSString))
            }
            
            cell!.textLabel.attributedText = attributedText
            
        case 1:
            let gameOpponentTurn = gamesWithOpponentTurn[Int(indexPath.row)] as PFObject
            var attributedText = NSMutableAttributedString()
            
            if gameOpponentTurn["user"].objectId == PFUser.currentUser().objectId {
                attributedText = NSMutableAttributedString(string: String(gameOpponentTurn["user2FullName"] as NSString))
            } else {
                attributedText = NSMutableAttributedString(string: String(gameOpponentTurn["userFullName"] as NSString))
            }
            cell!.textLabel.attributedText = attributedText
        default:
            fatalError("What the fuck did you think ??")
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            var game : PFObject = gamesWithUserTurn[Int(indexPath.row)] as PFObject
            openGame(game, userTurn: true)
        case 1:
            var game : PFObject = gamesWithOpponentTurn[Int(indexPath.row)] as PFObject
        
            openGame(game, userTurn: false)
        default:
            fatalError("What the fuck did you think ??")
        }
        
        currentGameIndex = indexPath.row
    }
    
    func loadTableViewContent() {
        var gameQuery = searchModule.findGame()
        
        gameQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                self.gamesWithUserTurn = []
                self.gamesWithOpponentTurn = []
                
                for object in objects as [PFObject] {
                    if object["userOnTurn"].objectId == PFUser.currentUser().objectId {
                        self.gamesWithUserTurn += [object]
                    } else {
                        self.gamesWithOpponentTurn += [object]
                    }
                }
                
                self.navigationItem.title = "Games"
                self.gameTableView.reloadData()
                self.setBadgeNumber()
            } else {
                let alert = UIAlertView(title: "Connection Failed", message: "There seems to be an error with your internet connection.", delegate: self, cancelButtonTitle: "Try Again")
                alert.show()
                
                println("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    func newGame() {
        self.navigationController!.pushViewController(addNewGameController(), animated: true)
    }
    
    func openGame(game : PFObject, userTurn : Bool) {
        let gameEngineController = GameEngineController()
        
        gameEngineController.gameObject = [game]
        gameEngineController.userTurn = userTurn
        self.navigationController!.pushViewController(gameEngineController, animated: true)
    }
    
    func addNavigationItems() {
        navigationItem.title = "Connecting..."
        var addNewGameBtn = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newGame") //Use a selector
        navigationItem.rightBarButtonItem = addNewGameBtn
        
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        gameTableView.reloadData()
        setBadgeNumber()
    }
    
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        var deleteAction = UITableViewRowAction(style: .Default, title: "Resign") { (action, indexPath) -> Void in
            tableView.editing = true
            
            switch indexPath.section {
            case 0:
                var game : PFObject = self.gamesWithUserTurn.at(indexPath.row)[0] as PFObject
                User.userResignedGame(game)
                self.gamesWithUserTurn.removeAtIndex(indexPath.self.row)
                self.gameTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                game.deleteEventually()
                
            case 1:
                var game : PFObject = self.gamesWithOpponentTurn.at(indexPath.row)[0] as PFObject
                User.userResignedGame(game)
                self.gamesWithOpponentTurn.removeAtIndex(indexPath.row)
                self.gameTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                game.deleteEventually()
                
            default:
                fatalError("What the fuck did you think ??")
            }
        }
        
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    }
    
    func setBadgeNumber () {
        var currentInstallation = PFInstallation.currentInstallation()
        
        if gamesWithUserTurn.count != 0 {
            currentInstallation.badge = gamesWithUserTurn.count
        } else {
            currentInstallation.badge = 0
        }
        
        currentInstallation.saveEventually()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}