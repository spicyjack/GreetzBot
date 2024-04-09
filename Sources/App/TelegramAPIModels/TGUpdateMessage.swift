//
//

import Vapor

struct TGUpdateMessage: Content {
    var update_id: Int64
    var message: TGMessage?
    var edited_message: TGMessage?
    var channel_post: TGMessage?
    var edited_channel_post: TGMessage?
}
