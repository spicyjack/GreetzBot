//  
//

import Vapor

struct TGChat: Content {
    var id: Int64
    var type: String
    var title: String?
    var first_name: String?
    var last_name: String?
    var username: String?

    func chatUserDetails() -> String {
        var details = String(id)
        details += "/"
        details += username ?? "[username]"
        details += " ("
        details += first_name ?? "[first]"
        details += " "
        details += last_name ?? "[last]"
        details += ")"
        return details
    }

}
