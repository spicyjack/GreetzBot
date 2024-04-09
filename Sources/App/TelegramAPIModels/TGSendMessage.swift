//  
//

import Vapor

struct TGSendMessage: TGAPISendable {
    var chat_id: Int64
    var parse_mode: String?
    var text: String
    var reply_markup: [String]?
}
