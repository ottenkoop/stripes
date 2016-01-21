//
//  demoController.swift
//  Stripes
//
//  Created by Koop Otten on 02/04/15.
//  Copyright (c) 2015 KoDev. All rights reserved.
//

import Foundation

class demoController: UIViewController {
//    private var gameBoardView = gameView(gameControl: UIViewController())
//    private var GameHandler = gameHandler(gameBoardV: gameView(gameControl: UIViewController()), localBoard: Board(dimension: 0), uBoard: Board(dimension: 0), oppBoard: Board(dimension: 0), weekB: [AnyObject](), dimension: 0, submitButton: UIButton())

//    var userTurn = false
//    var gameObject = PFObject(className:"currentGame")
//
//    var gridDimension : Int = 0
//    internal var localGameBoard = Board(dimension: 0)
//    var userBoard = Board(dimension: 0)
//    var opponentBoard = Board(dimension: 0)
//
//    var submitBtn = UIButton()
//    var specialsBtn = UIButton()
//    var specialUsed : Bool = false
//
//    var stripeToSubmit : UIButton = UIButton()
//    var doubleStripeToSubmit : UIButton = UIButton()
//    var scoredSquaresArray : [UIView] = []
    
    override func viewDidLoad() {
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gameBackground")!)
        
        print(Game.currentGame())
    }
}
