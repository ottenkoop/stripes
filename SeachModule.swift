//

import Foundation

class searchModule: PFObject {
    
    class func findGame() -> PFQuery {
        let predicate = NSPredicate(format: "user = %@ OR user2 = %@", PFUser.currentUser(), PFUser.currentUser())
        var game = PFQuery(className: "Game", predicate: predicate)
        
        return game
    }
}