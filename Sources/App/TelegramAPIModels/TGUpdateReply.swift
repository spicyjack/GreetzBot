//
//

import Vapor

struct TGUpdateReply: TGAPISendable {
    var method: String
    var chat_id: Int64
    var message_id: Int64?
    var parse_mode: String?
    var text: String
    var reply_markup: [String]?
}
