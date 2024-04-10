//
//
//
//

import Vapor
import Fluent
import Lingo

struct GreetzBotController: RouteCollection {
    private let lingo: Lingo

    init(_ lingo: Lingo) {
        self.lingo = lingo
    }

    func boot(routes:RoutesBuilder) throws {
        routes.post("", use: webhookHandler)
    }

    func webhookHandler(_ req: Request) async throws -> HTTPStatus {
        guard let rawRequestBody = req.body.string else {
            // ALWAYS return HTTP 200 to the API server
            req.logger.error("No request body found in HTTP request!")
            throw Abort(.ok)
        }

        // remove the newline/linefeed (0x0a or \n) at the end of '{"update_id":28579590,'
        let requestBody = rawRequestBody.replacingOccurrences(of: "\n", with: "")
        print("Request body: \(requestBody)")

        let updateMsg = try req.content.decode(TGUpdateMessage.self)
        guard let message = updateMsg.message else {
            throw Abort(.ok)
        }
        let chatID = message.chat.id
        guard let messageText = updateMsg.message?.text else {
            throw Abort(.ok)
        }
        print("-> Message text: \(messageText)")
        
        let scrubber = MarkdownScrubber()
        let scrubbedText = scrubber.escapeMarkdown(messageText)
        let localizedTitle = lingo.localize("title", locale: "en")
//        let localizedTitle = lingo.localize("title", locale: "ru")
        let replyText = "\(localizedTitle)! \(scrubbedText)"
        let msg = TGSendMessage(chat_id: chatID,
                                parse_mode: "MarkdownV2",
                                text: replyText)
        let messagesToQueue = TGSendMessagesToQueue(messageReceiverID: chatID, messages: [msg])
        let queueHelper = QueueHelper(req.queue)
        try await queueHelper.enqueueTGSendMessages(messagesToQueue)
        return .ok
    }
}

