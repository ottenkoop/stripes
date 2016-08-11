//
//  userRandomGames.swift
//  Stripes
//
//  Created by Koop Otten on 10/08/2016.
//  Copyright © 2016 KoDev. All rights reserved.
//

class userRandomGame: PFObject {
    
    class func newUserRandomGameQueue(withSpecials: Bool) {
        let randomGame = PFObject(className:"userRandomGameQueue")

        randomGame["user"] = PFUser.currentUser()!
        randomGame["withSpecials"] = withSpecials
        
        randomGame.saveInBackground()
    }
    
    class func gameAvailable(withSpecials: Bool) -> Bool {
        // find userRandomGameQueue objects
        var usersInQueue : [PFObject] = findUserRandomGameQueue(withSpecials)
        
        if usersInQueue.count >= 1 {
            // check if game exists
            print(usersInQueue)
            var usersInQueueClone : [PFObject] = []
            
            for randomGame in usersInQueue {
                if !(searchModule.checkIfGameAlreadyExcists(randomGame["user"] as! PFUser)) {
                    usersInQueueClone += [randomGame]
                }
            }
            
            usersInQueue = usersInQueueClone
        }
        
        if usersInQueue.count == 0 {
            // if it is still 0 > add user to queue
            if shouldWeAddUserToQueue(withSpecials) {
                newUserRandomGameQueue(withSpecials)
            }
            
            return false
        } else {
            let randomGameToPlay : PFObject = usersInQueue.first!
            let opponent = randomGameToPlay["user"] as! PFUser
            
            // if a match is found > 1. create game. 2. delete object from queue.
            Game.addGame(opponent, gameWithSpecials: withSpecials, grid: 3) 
            randomGameToPlay.deleteEventually()
            
            return true
        }
    }
    
    class func findUserRandomGameQueue(withSpecials: Bool) -> [PFObject] {
        let predicate = NSPredicate(format: "user != %@ AND withSpecials = %@", PFUser.currentUser()!, withSpecials)
        let query = PFQuery(className: "userRandomGameQueue", predicate: predicate)
        
        return executeRandomUserGameQuery(query)
    }
    
    class func shouldWeAddUserToQueue(withSpecials: Bool) -> Bool {
        let predicate = NSPredicate(format: "user = %@ AND withSpecials = %@", PFUser.currentUser()!, withSpecials)
        let query = PFQuery(className: "userRandomGameQueue", predicate: predicate)
        
        return executeRandomUserGameQuery(query).count == 0
    }
    
    class func executeRandomUserGameQuery(query: PFQuery) -> [PFObject] {
        query.orderByDescending("updatedAt")
        
        var usersInQueue = [PFObject]()
        do { usersInQueue = try query.findObjects() } catch {}
        
        return usersInQueue
        
    }
}