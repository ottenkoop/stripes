//

import Foundation

class searchModule: PFObject {
    
    class func findGame() -> PFQuery {
        let predicate = NSPredicate(format: "user = %@ OR user2 = %@", PFUser.currentUser(), PFUser.currentUser())
        var game = PFQuery(className: "Game", predicate: predicate)
        
        return game
    }
    
    class func findPlayedStripes(game: PFObject) -> PFQuery {
        let predicate = NSPredicate(format: "belongsToGame = %@", game)
        var playedStripesQuery = PFQuery(className: "Stripe", predicate: predicate)
        
        return playedStripesQuery
    }
}