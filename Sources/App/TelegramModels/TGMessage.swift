//  
//

import Vapor

struct TGMessage: Content {
    var message_id: Int64
    var from: TGUser?
    var sender_chat: TGChat?
    var date: Int32
    var chat: TGChat
    var text: String?
}
