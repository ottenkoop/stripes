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
    var timerView : UIView = UIView()
    
    var dayTimer = UILabel()
    var hourTimer = UILabel()
    var minuteTimer = UILabel()
    var secondsTimer = UILabel()
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    var gamesWithUserTurn : [PFObject] = []
    var gamesWithOpponentTurn : [PFObject] = []
    var currentGameIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameTableView.backgroundColor = UIColor(patternImage: UIImage(named: "gameBackground")!)

        addTimer()
        addRefreshTableDrag()
        addTableView()
        addNavigationItems()
        
        addBannerView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadTableViewContent", name: "reloadGameTableView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteObjectFromSection", name: "deleteObjectFromYourTurnSection", object: nil)
    }
    
    func addTimer() {
        var titleView = UILabel()
        
        var dayText = UILabel()
        var hourText = UILabel()
        var minuteText = UILabel()
        var secondsText = UILabel()
        
        var margin = (navigationController!.navigationBar.bounds.height) + (UIApplication.sharedApplication().statusBarFrame.size.height)
        
        self.view.addSubview(timerView)
        
        timerView.addSubview(titleView)
        timerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        timerView.constrainToHeight(60)
        timerView.backgroundColor = UIColor.whiteColor()
        
        titleView.text = "Time left this round:"
        titleView.font = UIFont(name: "HanziPen SC", size: 12)
        titleView.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleView.centerInContainerOnAxis(.CenterX)
        titleView.pinAttribute(.Top, toAttribute: .Top, ofItem: timerView, withConstant: 5)
        
        timerView.pinAttribute(.Top, toAttribute: .Top, ofItem: self.view, withConstant: margin)
        timerView.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view)
        timerView.pinAttribute(.Right, toAttribute: .Right, ofItem: self.view)
        
        addTimerViews()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateCountdown", userInfo: nil, repeats: true)
    }
    
    func addTimerViews() {
        var dayTimerView = UIView()
        var hourTimerView = UIView()
        var minuteTimerView = UIView()
        var secondsTimerView = UIView()
        
        timerView.addSubview(dayTimerView)
        timerView.addSubview(hourTimerView)
        timerView.addSubview(minuteTimerView)
        timerView.addSubview(secondsTimerView)
        
        styleTimerViews([dayTimerView, hourTimerView, minuteTimerView, secondsTimerView])
    }
    
    func styleTimerViews(views : [UIView]) {
        for (index, view) in enumerate(views) {
            
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.constrainToSize(CGSizeMake((screenWidth / 4) - 3, 40))
            view.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: timerView)
            
            if index == 0 {
                view.pinAttribute(.Left, toAttribute: .Left, ofItem: timerView, withConstant: 10)
            } else {
                view.pinAttribute(.Left, toAttribute: .Right, ofItem: views[index - 1], withConstant: 2)
            }
        }
        
        views[0].addSubview(dayTimer)
        views[1].addSubview(hourTimer)
        views[2].addSubview(minuteTimer)
        views[3].addSubview(secondsTimer)

        styleTimerLabels([dayTimer, hourTimer, minuteTimer, secondsTimer])
        
        dayTimer.centerInView(views[0])
        hourTimer.centerInView(views[1])
        minuteTimer.centerInView(views[2])
        secondsTimer.centerInView(views[3])
        
        updateCountdown()
    }
    
    func styleTimerLabels(views : [UILabel]) {
        for view in views {
            view.font = UIFont(name: "HanziPen SC", size: 30)
            view.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.constrainToSize(CGSizeMake(75, 50))
        }
    }

    func updateCountdown() {
        var date = NSDate()
        var monday = NSDate().dateAtStartOfWeek().dateByAddingDays(1)
        
        var dayString:NSString = "\(date.daysBeforeDate(monday)) days"
        var hourString:NSString = "\(date.hoursBeforeDate(date.dateAtEndOfDay())) hours"
        var minuteString:NSString = "\(59 - date.minute()) min"
        var secondsString:NSString = "\(59 - date.seconds()) sec"
        
        var dayTimerString = NSMutableAttributedString()
        var hourTimerString = NSMutableAttributedString()
        var minuteTimerString = NSMutableAttributedString()
        var secondsTimerString = NSMutableAttributedString()
        
        dayTimerString = NSMutableAttributedString(string: dayString, attributes: [NSFontAttributeName:UIFont(name: "HanziPen SC", size: 18.0)!])
        hourTimerString = NSMutableAttributedString(string: hourString, attributes: [NSFontAttributeName:UIFont(name: "HanziPen SC", size: 18.0)!])
        minuteTimerString = NSMutableAttributedString(string: minuteString, attributes: [NSFontAttributeName:UIFont(name: "HanziPen SC", size: 18.0)!])
        secondsTimerString = NSMutableAttributedString(string: secondsString, attributes: [NSFontAttributeName:UIFont(name: "HanziPen SC", size: 18.0)!])

        // style the label.
        styleTimerString(dayTimerString, stringLength: dayString.length, attributeLength: 4)
        styleTimerString(hourTimerString, stringLength: hourString.length, attributeLength: 5)
        styleTimerString(minuteTimerString, stringLength: minuteString.length, attributeLength: 3)
        styleTimerString(secondsTimerString, stringLength: secondsString.length, attributeLength: 3)

        //Apply to the label
        dayTimer.attributedText = dayTimerString
        hourTimer.attributedText = hourTimerString
        minuteTimer.attributedText = minuteTimerString
        secondsTimer.attributedText = secondsTimerString

    }
    
    func styleTimerString(MuString: NSMutableAttributedString, stringLength: Int, attributeLength: Int) {
        MuString.addAttribute(NSFontAttributeName, value: UIFont(name: "HanziPen SC", size: 30.0)!, range: NSRange(location: 0,length: 2))
        MuString.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0), range: NSRange(location:0,length:2))
        MuString.addAttribute(NSFontAttributeName, value: UIFont(name: "HanziPen SC", size: 14.0)!, range: NSRange(location: (stringLength - attributeLength), length: attributeLength))
        MuString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: (stringLength - attributeLength),length:attributeLength))
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
        gameTableView.rowHeight = 60.0
        
        gameTableView.pinAttribute(.Top, toAttribute: .Bottom, ofItem: timerView)
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

//            var aView = UIImageView(image: UIImage(named: "disclosureIndicator"))
//            aView.frame = CGRectMake(0, 0, 10, 20)
////            cell!.accessoryView = aView
//            cell!.selectionStyle = UITableViewCellSelectionStyle.Blue
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
        var oppName = UILabel()
        var pointsView = UILabel()
        var userName = UILabel()
        var oppPoints : Int = 0
        var uPoints : Int = 0
        var oppFullName = []
        
        if weekBattle["user"].objectId == PFUser.currentUser().objectId {
            uPoints = weekBattle["userPoints"] as Int
            oppPoints = weekBattle["user2Points"] as Int
            oppFullName = (weekBattle["user2FullName"] as NSString).componentsSeparatedByString(" ")
        } else {
            oppPoints = weekBattle["userPoints"] as Int
            uPoints = weekBattle["user2Points"] as Int
            oppFullName = (weekBattle["userFullName"] as NSString).componentsSeparatedByString(" ")
        }

        if oppFullName.count > 1 {
            var lastName = oppFullName.lastObject as String
            var lastLetter = lastName[lastName.startIndex]
            
            oppName.text = "\(oppFullName[0]) \(lastLetter)."
        } else {
            oppName.text = "\(oppFullName[0])"
        }

        userName.text = "Me"
        pointsView.text = "\(oppPoints)  :  \(uPoints)"
        
        cell.contentView.addSubview(oppName)
        cell.contentView.addSubview(pointsView)
        cell.contentView.addSubview(userName)
        
        oppName.setTranslatesAutoresizingMaskIntoConstraints(false)
        userName.setTranslatesAutoresizingMaskIntoConstraints(false)
        pointsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        oppName.font = UIFont (name: "HanziPen SC", size: 16)
        oppName.pinAttribute(.Left, toAttribute: .Left, ofItem: cell, withConstant: 20)
        oppName.centerInContainerOnAxis(.CenterY)

        userName.font = UIFont (name: "HanziPen SC", size: 16)
        userName.pinAttribute(.Right, toAttribute: .Right, ofItem: cell, withConstant: -20)
        userName.centerInContainerOnAxis(.CenterY)
        
        pointsView.font = UIFont (name: "HanziPen SC", size: 30)
        pointsView.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
        pointsView.centerInView(cell)
//        pointsView.centerInContainerOnAxis(.CenterY)
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
        var weekBattlesQuery = searchModule.findWeekBattles()
        
        weekBattlesQuery.findObjectsInBackgroundWithBlock {
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
                
                self.navigationItem.title = "Battles"
                self.gameTableView.reloadData()
                self.setBadgeNumber()
            } else {
                let alert = UIAlertView(title: "Connection Failed", message: "There seems to be an error with your internet connection.", delegate: self, cancelButtonTitle: "Try Again")
                alert.show()
                
                println("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    func openGame(weekBattle : PFObject, userTurn : Bool) {
        SVProgressHUD.show()
        
        var gameQuery = searchModule.findGame(weekBattle["currentGame"].objectId)

        gameQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                let gameEngineController = newGameController()
                var game : PFObject = objects[0] as PFObject
                
                gameEngineController.gameObject = [game]
                gameEngineController.weekBattle = [weekBattle]
                gameEngineController.userTurn = userTurn
                self.navigationController!.pushViewController(gameEngineController, animated: true)
            }
        }
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
        
//        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gameBackground"), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
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