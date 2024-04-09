//
//

import Vapor
import Queues

final class QueueHelper: QueueAdaptable {
   private let queue: Queue

   init(_ queue: Queue) {
      self.queue = queue
   }

   func enqueueTGSendMessages(_ msg: TGSendMessagesToQueue) async throws {
       try await queue.dispatch(SendTelegramAPIMessageJob.self,
                                .init(messageReceiverID: msg.messageReceiverID,
                                      messages: msg.messages))
   }
}

