//  
//

import Vapor

// https://core.telegram.org/bots/api#making-requests
struct TGResponseSendMessage: Content {
    var ok: Bool
    var description: String?
    var result: TGSendMessage?
}
