//

import Foundation

class searchModule: PFObject {
    
    class func findGame(gameId : NSString) -> PFQuery {
        let query = PFQuery(className:"Game")
        query.whereKey("objectId", equalTo:"\(gameId)")
        
        return query
    }
    
    class func findAllGamesForUser() -> PFQuery {
        let predicate = NSPredicate(format: "user = %@ OR user2 = %@", PFUser.currentUser()!, PFUser.currentUser()!)
        let game = PFQuery(className: "Game", predicate: predicate)
        
        return game
    }
    
    class func findUsers(searchString : String) -> PFQuery {
        let usersQuery = PFUser.query()
        
        usersQuery!.whereKey("fullName", matchesRegex: searchString, modifiers: "i")
        return usersQuery!
    }
    
    class func findUserWithObjectId(searchString : String) -> PFQuery {
        let usersQuery = PFUser.query()
        
        usersQuery!.whereKey("objectId", matchesRegex: searchString, modifiers: "i")
        return usersQuery!
    }
    
    class func checkIfGameAlreadyExcists(opponent : PFUser) -> Bool {
        let predicate = NSPredicate(format: "user = %@ AND user2 = %@ OR user2 = %@ AND user = %@", PFUser.currentUser()!, opponent, PFUser.currentUser()!, opponent)
        let gameQuery = PFQuery(className: "Game", predicate: predicate)
        
        var gameExists = false
        
        do {
            let results = try gameQuery.findObjects()
            if results.count > 0 {
                gameExists = true
            }
        } catch {
            gameExists = false
        }
        
        return gameExists
    }
    
}