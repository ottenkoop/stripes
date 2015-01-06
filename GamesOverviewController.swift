//
//  GamesOverviewController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 16/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation
import iAd

class GameOverviewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate {
    
    let bannerView = ADBannerView()
    var gameTableView : UITableView = UITableView()
    var cell : UITableViewCell?
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    var gamesWithUserTurn : [PFObject] = []
    var gamesWithOpponentTurn : [PFObject] = []
    var currentGameIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameTableView.backgroundColor = UIColor(patternImage: UIImage(named: "gameBackground")!)

        addRefreshTableDrag()
        addTableView()
        addNavigationItems()
        
        addBannerView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadTableViewContent", name: "reloadGameTableView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteObjectFromSection", name: "deleteObjectFromYourTurnSection", object: nil)
    }
    
    func deleteObjectFromSection() {
        var game : PFObject = gamesWithUserTurn[currentGameIndex] as PFObject

        gamesWithUserTurn.removeAtIndex(currentGameIndex)
        loadTableViewContent()
    }
    
    func addNewGameBtn() {
        let newGameBtn = UIButton()
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
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        gameTableView.addSubview(refreshControl)
    }
    
    func refresh (sender: UIRefreshControl) {
        loadTableViewContent()
        
        sender.endRefreshing()
    }
    
    func addTableView() {
        gameTableView.delegate = self
        gameTableView.dataSource = self
        
        self.gameTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(gameTableView)
        
        gameTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        gameTableView.separatorColor = UIColor.colorWithRGBHex(0xD2D2D2, alpha: 0.4)
        
        gameTableView.pinAttribute(.Top, toAttribute: .Top, ofItem: self.view)
        gameTableView.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: self.view)
        gameTableView.pinAttribute(.Right, toAttribute: .Right, ofItem: self.view)
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
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView! {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        label.textAlignment = NSTextAlignment.Center

        label.backgroundColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 0.7)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont (name: "", size: 14)
        
        switch section {

        case 0:
            label.text = "Your Turn"
        case 1:
            label.text = "Their Turn"
        default:
            label.text = ""
        }

        return label
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = gameTableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell

        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()

            var aView = UIImageView(image: UIImage(named: "disclosureIndicator"))
            aView.frame = CGRectMake(0, 0, 10, 20)
            cell!.accessoryView = aView
            cell!.selectionStyle = UITableViewCellSelectionStyle.Blue
        }
        
        switch indexPath.section {
        case 0:
            let gameUserTurn = gamesWithUserTurn[Int(indexPath.row)] as PFObject
            var attributedText = ""
            
            if gameUserTurn["user"].objectId == PFUser.currentUser().objectId {
                attributedText = String(gameUserTurn["user2FullName"] as NSString)
            } else {
                attributedText = String(gameUserTurn["userFullName"] as NSString)
            }
            
            cell!.textLabel?.text = attributedText
            
        case 1:
            let gameOpponentTurn = gamesWithOpponentTurn[Int(indexPath.row)] as PFObject
            var attributedText = ""
            
            if gameOpponentTurn["user"].objectId == PFUser.currentUser().objectId {
                attributedText = String(gameOpponentTurn["user2FullName"] as NSString)
            } else {
                attributedText = String(gameOpponentTurn["userFullName"] as NSString)
            }
            
            cell!.textLabel?.text = attributedText
        default:
            fatalError("What did you think ??")
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
            fatalError("What did you think ??")
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
    
    func openGame(game : PFObject, userTurn : Bool) {
        let gameEngineController = newGameController()

        gameEngineController.gameObject = [game]
        gameEngineController.userTurn = userTurn
        self.navigationController!.pushViewController(gameEngineController, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        gameTableView.reloadData()
        setBadgeNumber()
        SVProgressHUD.dismiss()
        
        navigationItem.leftBarButtonItem?.enabled = true
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        var deleteAction = UITableViewRowAction(style: .Default, title: "Resign") { (action, indexPath) -> Void in
            tableView.editing = true
            
            switch indexPath.section {
            case 0:
                var game : PFObject = self.gamesWithUserTurn.at(indexPath.row)[0] as PFObject
                pushNotificationHandler.userResignedGame(game)
                self.gamesWithUserTurn.removeAtIndex(indexPath.self.row)
                self.gameTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                game.deleteEventually()
                
            case 1:
                var game : PFObject = self.gamesWithOpponentTurn.at(indexPath.row)[0] as PFObject
                pushNotificationHandler.userResignedGame(game)
                self.gamesWithOpponentTurn.removeAtIndex(indexPath.row)
                self.gameTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                game.deleteEventually()
                
            default:
                fatalError("What did you think ??")
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
    
    func addNavigationItems() {
        navigationItem.title = "Connecting..."
        var addNewGameBtn = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newGame")
        var settingsMenu = UIBarButtonItem(image: UIImage(named: "settingsIcon"), style: .Plain, target: self, action: "openSettings")
        
        navigationItem.rightBarButtonItem = addNewGameBtn
        navigationItem.leftBarButtonItem = settingsMenu
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gameBackground"), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.translucent = true
    }
    
    func openSettings() {
        let settingsV = settingsView()
        
        navigationController!.pushViewController(settingsV, animated: true)
    }
    
    func newGame() {
        var btns = newGamePopup().openPopup(self)
        
        btns[0].addTarget(self, action: "faceBookFriendGame:", forControlEvents: .TouchUpInside)
        btns[1].addTarget(self, action: "searchingForUsername:", forControlEvents: .TouchUpInside)
        
        btns[3].addTarget(self, action: "cancelBtnPressed:", forControlEvents: .TouchUpInside)
        
        navigationItem.leftBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.enabled = false
    }
    
    func faceBookFriendGame(fButton : UIButton!) {
        var newGame = addNewGameController()
        
        newGame.showFaceBookFriends = true
        
        navigationController!.pushViewController(newGame, animated: true)
        newGamePopup().removePopup(fButton)
    }
    
    func searchingForUsername(uButton : UIButton!) {
        var newGame = addNewGameController()
        
        newGame.showFaceBookFriends = false
        
        navigationController!.pushViewController(newGame, animated: true)
        newGamePopup().removePopup(uButton)
    }
    
    func cancelBtnPressed(cButton : UIButton!) {
        newGamePopup().cancelPopup(cButton)
        
        var addNewGameBtn = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newGame")
        var settingsMenu = UIBarButtonItem(image: UIImage(named: "settingsIcon"), style: .Plain, target: self, action: "openSettings")
        
        navigationItem.leftBarButtonItem?.enabled = true
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    //iAd
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        println("start")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        // self.bannerView.alpha = 1.0
        println("goed!")
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        println("gefinished")
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        println("...")
        return true 
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        println("ging iets Fout")
        self.bannerView.alpha = 0.0
    }
    
    func addBannerView() {
        self.view.addSubview(bannerView)
        self.bannerView.delegate = self
        
        bannerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bannerView.constrainToHeight(bannerView.bounds.height)
        bannerView.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: self.view)
        bannerView.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view)
        bannerView.pinAttribute(.Right, toAttribute: .Right, ofItem: self.view)
        
        bannerView.alpha = 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}