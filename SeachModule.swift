//

import Foundation

class searchModule: PFObject {
    
    class func findGame(gameId : NSString) -> PFQuery {
        let query = PFQuery(className:"Game")
        query.whereKey("objectId", equalTo:"\(gameId)")
        
        return query
    }
    
    class func findWeekBattles() -> PFQuery {
        let predicate = NSPredicate(format: "user = %@ OR user2 = %@", PFUser.currentUser()!, PFUser.currentUser()!)
        let game = PFQuery(className: "weekBattle", predicate: predicate)
        
        return game
    }
    
    class func findUsers(searchString : String) -> PFQuery {
        let usersQuery = PFUser.query()
        
        usersQuery!.whereKey("fullName", matchesRegex: searchString, modifiers: "i")
        return usersQuery!
    }
}