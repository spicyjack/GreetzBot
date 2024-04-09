//
//

import Vapor

protocol TGAPISendable: Content {
    var chat_id: Int64 { get }
    var parse_mode: String? { get }
    var text: String { get }
}
