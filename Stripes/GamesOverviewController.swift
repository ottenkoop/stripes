//
//  GamesOverviewController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 16/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation
import Crashlytics


class GameOverviewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var gameTableView : UITableView = UITableView()
    var cell : UITableViewCell?
    var interstitialAdView: UIView = UIView()
    var loadingViewContainer: UIView = UIView()
    var showAdToUser : Bool = false
    
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
        emptyLocalPinnedObjects()
        loadTableViewContent()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameOverviewController.loadTableViewContent), name: "reloadGameTableView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(User.resetLookingForGame), name: "resetLookingForGame", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameOverviewController.deleteObjectFromSection), name: "deleteObjectFromYourTurnSection", object: nil)
        
        if (PFUser.currentUser()!["fullName"] == nil || PFUser.currentUser()!["email"] == nil) && (PFUser.currentUser()!["fbId"] != nil) {
            User.requestFaceBookLoggedInUserInfo()
        }
    }
    
    func deleteObjectFromSection() {
        showAdToUser = true
        
        gamesWithUserTurn.removeAtIndex(currentGameIndex)

        loadTableViewContent()
    }
    
    func resetCurrentGame() {
//        currentGame = PFObject()
    }
    
    func addNewGameBtn() {
        let newGameBtn = UIButton()
        let navBar = navigationController?.navigationBar
        
        newGameBtn.backgroundColor = UIColor.colorWithRGBHex(0x5AB103)
        newGameBtn.setTitle("New Game", forState: .Normal)
        newGameBtn.addTarget(self, action: #selector(GameOverviewController.newGame), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(newGameBtn)
        newGameBtn.translatesAutoresizingMaskIntoConstraints = false

        newGameBtn.pinAttribute(.Top, toAttribute: .Bottom, ofItem: navBar, withConstant: 0)
    }
    
    func addRefreshTableDrag() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(GameOverviewController.refresh(_:)), forControlEvents: .ValueChanged)
        
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
            if (Int(indexPath.row)) < gamesWithUserTurn.count {
                let gameUserTurn = gamesWithUserTurn[Int(indexPath.row)] as PFObject
                addCustomCellContent(cell!, gameObject: gameUserTurn)
            } else {
                reloadGameTableView()
            }
        case 1:
            if (Int(indexPath.row)) < gamesWithOpponentTurn.count {
                let gameOpponentTurn = gamesWithOpponentTurn[Int(indexPath.row)] as PFObject
                
                addCustomCellContent(cell!, gameObject: gameOpponentTurn)
            } else {
                reloadGameTableView()
            }
        default:
            fatalError("What did you think ??")
        }
        
        return cell!
    }
    
    func addCustomCellContent(cell: UITableViewCell, gameObject: PFObject ) {
        let userIsPFUser = gameObject["user"].objectId == PFUser.currentUser()!.objectId ? true : false
        
        let oppName = UILabel()
        let pointsView = UILabel()
        let userName = UILabel()
        var oppPoints : Int = 0
        var uPoints : Int = 0
        var oppFullName = []
        
        uPoints = userIsPFUser ? gameObject["userPoints"] as! Int : gameObject["opponentPoints"] as! Int
        oppPoints = userIsPFUser ? gameObject["opponentPoints"] as! Int : gameObject["userPoints"] as! Int
        
        oppFullName = userIsPFUser ? (gameObject["user2FullName"] as! NSString).componentsSeparatedByString(" ") : (gameObject["userFullName"] as! NSString).componentsSeparatedByString(" ")

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
            currentGame = gamesWithUserTurn[Int(indexPath.row)] as PFObject
        case 1:
            currentGame = gamesWithOpponentTurn[Int(indexPath.row)] as PFObject
        default:
            fatalError("What did you think ??")
        }
        
        openGame()
        
        currentGameIndex = indexPath.row
    }
    
    func warnBlockingOperationOnMainThread() {
        
    }

    func loadTableViewContent() {
        navigationItem.title = "Refreshing..."
        let gamesQuery = searchModule.findAllGamesForUser()

        gamesQuery.findObjectsInBackground().continueWithBlock {
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
    
    func openGame() {
//        let containerToRemove = loadingView().showActivityIndicator(self.view)
        changeNavigationItemEnableStatus(false)
        
        self.pushGameEngineController()
    }
    
    func pushGameEngineController() {
        dispatch_async(dispatch_get_main_queue()) {
            let gC = gameEngineController()
            self.navigationController?.pushViewController(gC, animated: true)
//            loadingView().hideActivityIndicatorWhenReturning(containerToRemove)
        }
    }
    
    func hideLoadingIndicator(containerToRemove: UIView) {
        dispatch_async(dispatch_get_main_queue()) {
            loadingView().hideActivityIndicatorWhenReturning(containerToRemove)
            self.changeNavigationItemEnableStatus(true)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setBadgeNumber()
        changeNavigationItemEnableStatus(true)
        
//        resetCurrentGame()
        reloadGameTableView()
        
        SVProgressHUD.dismiss()
        
//      enable for later; TO MAKE MORE MONEYSSSS
//        if showAdToUser {
//            self.navigationController?.navigationBarHidden = true
//            NSNotificationCenter.defaultCenter().postNotificationName("loadInterstitialAd", object: nil)
//        }
        
    }
    
    func reloadGameTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.gameTableView.reloadData()
            self.navigationItem.title = "Your Battles"
        }
    }
    
    func emptyLocalPinnedObjects() {
        do {
            try PFObject.unpinAllObjects()
        } catch {
            print("niet jeej")
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
    }
    
    func addNavigationItems() {
        navigationItem.title = "Connecting..."
        let addNewGameBtn = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(GameOverviewController.newGame))
        let settingsMenu = UIBarButtonItem(image: UIImage(named: "settingsIcon"), style: .Plain, target: self, action: #selector(GameOverviewController.openSettings))
        
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
        
        btns[0].addTarget(self, action: #selector(GameOverviewController.faceBookFriendGame(_:)), forControlEvents: .TouchUpInside)
        btns[1].addTarget(self, action: #selector(GameOverviewController.searchingForUsername(_:)), forControlEvents: .TouchUpInside)
        btns[2].addTarget(self, action: #selector(GameOverviewController.randomGame(_:)), forControlEvents: .TouchUpInside)
        btns[3].addTarget(self, action: #selector(GameOverviewController.cancelBtnPressed(_:)), forControlEvents: .TouchUpInside)
        
        changeNavigationItemEnableStatus(false)
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
        newGamePopup().removePopup(rButton)
        let gameOptionBtns = newGameTypeOptionsPopup().openPopup(self.view)
        
        gameOptionBtns[0].addTarget(self, action: #selector(GameOverviewController.randomGameStart(_:)), forControlEvents: .TouchUpInside)
        gameOptionBtns[1].addTarget(self, action: #selector(GameOverviewController.randomGameStart(_:)), forControlEvents: .TouchUpInside)
        gameOptionBtns[2].addTarget(self, action: #selector(GameOverviewController.randomGamePopupClose(_:)), forControlEvents: .TouchUpInside)
    }
    
    func randomGameStart(btn: UIButton) {
        let containerToRemove = loadingView().showActivityIndicator(self.view)
        let withSpecials = (btn.tag == 1) ? false : true
        
        0.1.waitSecondsAndDo({
            let gameFound : Bool = userRandomGame.gameAvailable(withSpecials)
            
            if gameFound {
                let alert = UIAlertView(title: "Opponent Found!", message: "Game is set up! You can start the game in the 'Your Turn' section.", delegate: self, cancelButtonTitle: "Ok")
                
                alert.show()
            } else {
                let alert = UIAlertView(title: "No Opponent Found.", message: "Searching for another opponent. Stripes will notify you when a game is available!", delegate: self, cancelButtonTitle: "Ok")
                alert.show()
            }
            
            loadingView().hideActivityIndicatorWhenReturning(containerToRemove)
            self.randomGamePopupClose(btn)
        })
        
        
    }
    
    func randomGamePopupClose(btn: UIButton!) {
        newGameTypeOptionsPopup().hidePopup(btn)
        changeNavigationItemEnableStatus(true)
    }
    
    func cancelBtnPressed(cButton : UIButton!) {
        newGamePopup().cancelPopup(cButton)
        changeNavigationItemEnableStatus(true)
    }
    
    func changeNavigationItemEnableStatus(status: Bool) {
        navigationItem.leftBarButtonItem?.enabled = status
        navigationItem.rightBarButtonItem?.enabled = status
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}