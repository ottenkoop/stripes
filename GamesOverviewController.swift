//
//  GamesOverviewController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 16/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation
import iAd
import Crashlytics


class GameOverviewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate, ADInterstitialAdDelegate {
    
    let bannerView = ADBannerView()
    var gameTableView : UITableView = UITableView()
    var cell : UITableViewCell?
    var interstitialAd:ADInterstitialAd!
    var interstitialAdView: UIView = UIView()

    //    TimerView is disabled for now
//    var timerView : UIView = UIView()
//    var dayTimer = UILabel()
//    var hourTimer = UILabel()
//    var minuteTimer = UILabel()
//    var secondsTimer = UILabel()
    
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
        loadTableViewContent()
        
        addBannerView()
        addUserFacebookInfo()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadTableViewContent", name: "reloadGameTableView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetLookingForGame", name: "resetLookingForGame", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteObjectFromSection", name: "deleteObjectFromYourTurnSection", object: nil)
        
        // iAD interstitial
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadInterstitialAd", name:"loadInterstitialAd", object: nil)
//        loadInterstitialAd()
        
//        PFUser.currentUser()["isSpecial"]
    }
    
    func addUserFacebookInfo() {
        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
            FBRequestConnection.startForMeWithCompletionHandler({
                (connection : FBRequestConnection!, result : AnyObject!, error : NSError!) -> Void in

                if error == nil {
                    PFUser.currentUser()!.setObject(result.objectForKey("id")!, forKey: "fbId")
                    PFUser.currentUser()!.saveInBackground()
                }
            })
        }
    }
    
    func styleTimerString(MuString: NSMutableAttributedString, stringLength: Int, attributeLength: Int) {
        MuString.addAttribute(NSFontAttributeName, value: UIFont(name: "HanziPen SC", size: 30.0)!, range: NSRange(location: 0,length: 2))
        MuString.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0), range: NSRange(location:0,length:2))
        MuString.addAttribute(NSFontAttributeName, value: UIFont(name: "HanziPen SC", size: 14.0)!, range: NSRange(location: (stringLength - attributeLength), length: attributeLength))
        MuString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: (stringLength - attributeLength),length:attributeLength))
    }
    
    func deleteObjectFromSection() {
        gamesWithUserTurn.removeAtIndex(currentGameIndex)
        loadTableViewContent()
    }
    
    func addNewGameBtn() {
        let newGameBtn = UIButton()
        let navBar = navigationController?.navigationBar
        
        newGameBtn.backgroundColor = UIColor.colorWithRGBHex(0x5AB103)
        newGameBtn.setTitle("New Game", forState: .Normal)
        newGameBtn.addTarget(self, action: "newGame", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(newGameBtn)
        newGameBtn.translatesAutoresizingMaskIntoConstraints = false

        newGameBtn.pinAttribute(.Top, toAttribute: .Bottom, ofItem: navBar, withConstant: 0)
    }
    
    func addRefreshTableDrag() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        
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
        
        gameTableView.translatesAutoresizingMaskIntoConstraints = false
        gameTableView.separatorColor = UIColor.colorWithRGBHex(0xD2D2D2, alpha: 0.4)
        gameTableView.rowHeight = 60.0
        
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Your Turn"
        case 1:
            return "Their Turn"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        var cell = gameTableView.dequeueReusableCellWithIdentifier("cell")

        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
        }
        
        switch indexPath.section {
        case 0:
            let gameUserTurn = gamesWithUserTurn[Int(indexPath.row)] as PFObject
            
            addCustomCellContent(cell!, weekBattle: gameUserTurn)
        case 1:
            let gameOpponentTurn = gamesWithOpponentTurn[Int(indexPath.row)] as PFObject
            
            addCustomCellContent(cell!, weekBattle: gameOpponentTurn)
        default:
            fatalError("What did you think ??")
        }
        
        return cell!
    }
    
    func addCustomCellContent(cell : UITableViewCell, weekBattle : PFObject ) {
        let oppName = UILabel()
        let pointsView = UILabel()
        let userName = UILabel()
        var oppPoints : Int = 0
        var uPoints : Int = 0
        var oppFullName = []
        
        if weekBattle["user"]!.objectId == PFUser.currentUser()!.objectId {
            uPoints = weekBattle["userPoints"] as! Int
            oppPoints = weekBattle["user2Points"] as! Int
            oppFullName = (weekBattle["user2FullName"] as! NSString).componentsSeparatedByString(" ")
        } else {
            oppPoints = weekBattle["userPoints"] as! Int
            uPoints = weekBattle["user2Points"] as! Int
            oppFullName = (weekBattle["userFullName"] as! NSString).componentsSeparatedByString(" ")
        }

        if oppFullName.count > 1 {
            let lastName = oppFullName.lastObject as! String
            let lastLetter = lastName[lastName.startIndex]
            
            oppName.text = "\(oppFullName[0]) \(lastLetter)."
        } else {
            oppName.text = "\(oppFullName[0])"
        }

        userName.text = "You"
        pointsView.text = "\(oppPoints)  :  \(uPoints)"
        
        cell.contentView.addSubview(oppName)
        cell.contentView.addSubview(pointsView)
        cell.contentView.addSubview(userName)
        
        oppName.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        pointsView.translatesAutoresizingMaskIntoConstraints = false
        
        oppName.font = UIFont (name: "HanziPen SC", size: 20)
        oppName.pinAttribute(.Left, toAttribute: .Left, ofItem: cell, withConstant: 20)
        oppName.centerInContainerOnAxis(.CenterY)

        userName.font = UIFont (name: "HanziPen SC", size: 20)
        userName.pinAttribute(.Right, toAttribute: .Right, ofItem: cell, withConstant: -20)
        userName.centerInContainerOnAxis(.CenterY)
        
        pointsView.font = UIFont (name: "HanziPen SC", size: 30)
        pointsView.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
        pointsView.centerInView(cell)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            let game : PFObject = gamesWithUserTurn[Int(indexPath.row)] as PFObject
            openGame(game)
        case 1:
            let game : PFObject = gamesWithOpponentTurn[Int(indexPath.row)] as PFObject
        
            openGame(game)
        default:
            fatalError("What did you think ??")
        }
        
        currentGameIndex = indexPath.row
    }
    
    func warnBlockingOperationOnMainThread() {
        
    }


    
    func loadTableViewContent() {
        navigationItem.title = "Refreshing..."
        let weekBattlesQuery = searchModule.findWeekBattles()

        weekBattlesQuery.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject in
            if task.error == nil {
                self.gamesWithUserTurn = []
                self.gamesWithOpponentTurn = []
                
                for object in task.result as! [PFObject] {
                    if object["userOnTurn"]!.objectId == PFUser.currentUser()!.objectId {
                        self.gamesWithUserTurn += [object]
                    } else {
                        self.gamesWithOpponentTurn += [object]
                    }
                }

                self.reloadGameTableView()
                self.setBadgeNumber()
            }
            return task
        }
    }
    
    func openGame(weekBattle : PFObject) {
        let containerToRemove = loadingView().showActivityIndicator(self.view)
        
        let gameQuery = searchModule.findGame(weekBattle["currentGame"].objectId as! NSString)
        
        gameQuery.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject in
            
            if let error = task.error {
                print("Error: \(error)")
                return task
            }
            
            let currentGame = PFObject(className: "currentGame")

            for object in task.result! as! [PFObject] {
                currentGame["object"] = object
            }
            
            do {
                try currentGame.pin()
            } catch {
                print("meh")
            }
            
            let gC = gameEngineController()
            gC.weekBattleObject = [weekBattle]

            dispatch_async(dispatch_get_main_queue(), {
                self.navigationController!.pushViewController(gC, animated: true)
                loadingView().hideActivityIndicatorWhenReturning(containerToRemove)
            })
            
            return task
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadGameTableView()
        setBadgeNumber()
        SVProgressHUD.dismiss()
        
//        emptyLocalPinnedObjects()
        
        navigationItem.leftBarButtonItem?.enabled = true
        navigationItem.rightBarButtonItem?.enabled = true
    }
    func reloadGameTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.gameTableView.reloadData()
            self.navigationItem.title = "Your Battles"
        }
        
        
    }
    
    func emptyLocalPinnedObjects() {
        let query = PFQuery(className:"currentGame")
        query.fromLocalDatastore()
        
        query.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject in
            for object in task.result! as! [PFObject] {
                object.unpinInBackground()
            }
            return task
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let row = indexPath.row
        let deleteAction = UITableViewRowAction(style: .Default, title: "Resign") { (action, indexPath) -> Void in
            tableView.editing = true
            
            switch indexPath.section {
            case 0:
                let game : PFObject = self.gamesWithUserTurn[row] as PFObject
                pushNotificationHandler.userResignedGame(game)
                self.gamesWithUserTurn.removeAtIndex(indexPath.self.row)
                self.gameTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                game.deleteEventually()
                
            case 1:
                let game : PFObject = self.gamesWithOpponentTurn[row] as PFObject
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func setBadgeNumber () {
        let currentInstallation = PFInstallation.currentInstallation()
        
        if gamesWithUserTurn.count != 0 {
            currentInstallation.badge = gamesWithUserTurn.count
        } else {
            currentInstallation.badge = 0
        }
        
        if currentInstallation.badge > 0 {
            User.resetLookingForGame()
        }
        
        currentInstallation.saveInBackground()
    }
    
    func addNavigationItems() {
        navigationItem.title = "Connecting..."
        let addNewGameBtn = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newGame")
        let settingsMenu = UIBarButtonItem(image: UIImage(named: "settingsIcon"), style: .Plain, target: self, action: "openSettings")
        
        navigationItem.rightBarButtonItem = addNewGameBtn
        navigationItem.leftBarButtonItem = settingsMenu
        
        navigationItem.setHidesBackButton(true, animated: false)
        
//        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gameBackground"), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = true
    }
    
    func openSettings() {
        let settingsC = settingsController()
        
        navigationController!.pushViewController(settingsC, animated: true)
    }
    
    func newGame() {
        let btns = newGamePopup().openPopup(self)
        
        btns[0].addTarget(self, action: "faceBookFriendGame:", forControlEvents: .TouchUpInside)
        btns[1].addTarget(self, action: "searchingForUsername:", forControlEvents: .TouchUpInside)
        btns[2].addTarget(self, action: "randomGame:", forControlEvents: .TouchUpInside)
        btns[3].addTarget(self, action: "cancelBtnPressed:", forControlEvents: .TouchUpInside)
        
        navigationItem.leftBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.enabled = false
    }
    
    func faceBookFriendGame(fButton : UIButton!) {
        let newGame = addNewGameController()
        
        newGame.showFaceBookFriends = true
        
        navigationController!.pushViewController(newGame, animated: true)
        newGamePopup().removePopup(fButton)
    }
    
    func searchingForUsername(uButton : UIButton!) {
        let newGame = addNewGameController()
        
        newGame.showFaceBookFriends = false
        
        navigationController!.pushViewController(newGame, animated: true)
        newGamePopup().removePopup(uButton)
    }
    
    func randomGame(rButton : UIButton!) {
        SVProgressHUD.show()
        let query = PFUser.query()
        query!.whereKey("lookingForGame", equalTo: true)
        
        var usersLookingForGame = []
        
        do {
            usersLookingForGame = try query!.findObjects()
        } catch {
            usersLookingForGame = []
        }
        
        if usersLookingForGame.count == 0 {
            let alert = UIAlertView(title: "", message: "Searching for an opponent. This may take a while.", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
            PFUser.currentUser()!.setObject(true, forKey: "lookingForGame")
            PFUser.currentUser()!.saveInBackground()
            SVProgressHUD.dismiss()
        } else {
            let int = Int(arc4random_uniform(UInt32(usersLookingForGame.count)))
            let opponent = usersLookingForGame[int] as! PFUser
            Game.addGame(opponent, grid: 3)

            SVProgressHUD.dismiss()
            newGamePopup().removePopup(rButton)
            
            navigationItem.leftBarButtonItem?.enabled = true
            navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    func cancelBtnPressed(cButton : UIButton!) {
        newGamePopup().cancelPopup(cButton)
        
        navigationItem.leftBarButtonItem?.enabled = true
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    //iAd
    func bannerViewWillLoadAd(banner: ADBannerView!) {
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        self.bannerView.alpha = 0.0
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        self.bannerView.alpha = 0.0
    }
    
    func addBannerView() {
        self.view.addSubview(bannerView)
        self.bannerView.delegate = self
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.constrainToHeight(bannerView.bounds.height)
        bannerView.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: self.view)
        bannerView.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view)
        bannerView.pinAttribute(.Right, toAttribute: .Right, ofItem: self.view)
        
        bannerView.alpha = 0.0
    }
    
    func loadInterstitialAd() {
        interstitialAd = ADInterstitialAd()
        interstitialAd.delegate = self
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        interstitialAdView = UIView()
        interstitialAdView.frame = self.view.bounds
        self.view.addSubview(interstitialAdView)
        
        interstitialAd.presentInView(interstitialAdView)
        self.navigationController?.navigationBarHidden = true
        
        UIViewController.prepareInterstitialAds()
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
        self.navigationController?.navigationBarHidden = false
    }
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}