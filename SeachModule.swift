//

import Foundation

class searchModule: PFObject {
    
    class func findGame(gameId : NSString) -> PFQuery {
        var query = PFQuery(className:"Game")
        query.whereKey("objectId", equalTo:"\(gameId)")
        
        return query
    }
    
    class func findWeekBattles() -> PFQuery {
        let predicate = NSPredicate(format: "user = %@ OR user2 = %@", PFUser.currentUser(), PFUser.currentUser())
        var game = PFQuery(className: "weekBattle", predicate: predicate)
        
        return game
    }
    
    class func findUsers(searchString : String) -> PFQuery {
        var usersQuery = PFUser.query()
        
        usersQuery.whereKey("fullName", hasPrefix: searchString)
        
        return usersQuery
    }
}