//
//  GamesOverviewController.swift
//  Tiles-swift
//
//  Created by Koop Otten on 16/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class GameOverviewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var gameTableView : UITableView = UITableView ()
    var cell : UITableViewCell?
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    var allGames : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        gameTableView.delegate = self
        gameTableView.dataSource = self

//        addNewGameBtn()
        addTableView()
        loadTableViewContent()
        addNavigationItems()
        
//        squareHandler.findSomething()
    }
    
    func addNewGameBtn() {
        let newGameBtn = UIButton ()
        var navBar = navigationController?.navigationBar
        
        newGameBtn.backgroundColor = UIColor.colorWithRGBHex(0x5AB103)
        newGameBtn.setTitle("New Game", forState: .Normal)
        newGameBtn.addTarget(self, action: "newGame", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(newGameBtn)
        newGameBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        newGameBtn.constrainToSize(CGSizeMake(screenWidth, 60))
        newGameBtn.pinAttribute(.Top, toAttribute: .Bottom, ofItem: navBar, withConstant: 0)
    }
    
    func addTableView() {
        self.gameTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(gameTableView)
        
        gameTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        gameTableView.constrainToSize(CGSizeMake(screenWidth, screenHeight - 150))
        gameTableView.pinAttribute(.Top, toAttribute: .Top, ofItem: self.view)
//        gameTableView.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = allGames.count as Int
        
        if count > 0 {
            return count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = gameTableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }

        let game = allGames[Int(indexPath.row)] as PFObject
        var userObjectId = ""
        
        if game["user"].objectId == PFUser.currentUser().objectId {
            userObjectId = game["user2"].objectId
        } else {
            userObjectId = game["user"].objectId
        }

        var opponentUserQuery = PFUser.query()
        opponentUserQuery.getObjectInBackgroundWithId("\(userObjectId)") {
            (opponentUser: PFObject!, error: NSError!) -> Void in
            if error != nil {
                NSLog("%@", error)
            } else {
                cell!.textLabel.text = String(opponentUser["fullName"] as NSString)
            }
        }

        cell!.detailTextLabel?.text = String(game.objectId as NSString)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var game : PFObject = allGames[Int(indexPath.row)] as PFObject
        
        openGame(game)
    }
    
    func loadTableViewContent() {
        var gameQuery = searchModule.findGame()
        
        gameQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.allGames = objects
                
                self.navigationItem.title = "Games"
                self.gameTableView.reloadData()
            } else {
                let alert = UIAlertView(title: "Connection Failed", message: "There seems to be an error with your internet connection.", delegate: self, cancelButtonTitle: "Try Again")
                alert.show()
                
                println("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    func newGame() {
        self.navigationController?.presentViewController(addNewGameController(), animated: true, completion: nil)
    }
    
    func openGame(game : PFObject) {
        let gameController = GameEngineController()
        
        gameController.gameObject = [game]
        self.presentViewController(gameController, animated: true, completion: nil)
    }
    
    func addNavigationItems() {
        navigationItem.title = "Connecting..."
        var addNewGameBtn = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newGame") //Use a selector
        navigationItem.rightBarButtonItem = addNewGameBtn
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}