//  
//

import Vapor

struct TGUser: Content, Equatable {
    var id: Int64
    var is_bot: Bool
    var first_name: String
    var last_name: String?
    var username: String?
    var language_code: String?

    static func == (lhs: TGUser, rhs: TGUser) -> Bool {
        // How to implement _Equatable_
        // https://stackoverflow.com/questions/30105272/
        return
            lhs.is_bot == rhs.is_bot
            && lhs.first_name == rhs.first_name
            && lhs.last_name == rhs.last_name
            && lhs.username == rhs.username
            && lhs.language_code == rhs.language_code
    }

    func userNameAndID() -> String {
        var details = String(id)
        details += "/"
        details += username ?? "[username]"
        return details
    }

    func userDetails() -> String {
        var details = String(id)
        details += "/"
        details += username ?? "[username]"
        details += " ("
        details += first_name
        details += " "
        details += last_name ?? "[last]"
        details += ")"
        return details
    }
}

