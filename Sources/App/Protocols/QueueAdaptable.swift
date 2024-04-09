//  
//

import Vapor
import Queues

struct TGSendMessagesToQueue: Codable {
    var messageReceiverID: Int64
    var messages: [TGSendMessage]
}

protocol QueueAdaptable {
    init(_ queue: Queue)
    func enqueueTGSendMessages(_ messages: TGSendMessagesToQueue) async throws
}
