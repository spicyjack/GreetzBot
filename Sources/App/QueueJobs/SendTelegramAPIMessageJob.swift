//  
//

import Vapor
import Queues

struct TGMessagesToSend: Codable {
    var messageReceiverID: Int64
    var messages: [TGSendMessage]
}

struct SendTelegramAPIMessageJob: AsyncJob {
    typealias Payload = TGMessagesToSend

    func dequeue(_ context: QueueContext, _ payload: TGMessagesToSend) async throws {
        let log = context.logger
        log.info("Sending queued message to ID: \(String(payload.messageReceiverID))")
        let telegramAPIToken = Environment.get("TELEGRAM_API_TOKEN") ?? ""
        let telegramURI = Environment.get("TELEGRAM_URI") ?? ""

        let client = AsyncTelegramClient(client: context.application.client,
                                         apiToken: telegramAPIToken,
                                         apiServer: telegramURI)
        for message in payload.messages {
            print("-> Sending message: \(message.text)")
            let response = try await client.sendMessage(message)
            var bodyString = ""
            if var body = response.body {
                bodyString = body.readString(length: body.readableBytes) ?? ""
            }

            if response.status == .ok {
                log.info("Telegram API Message sent successfully")
                log.info("Response HTTP status: \(response.status)")
                log.info("Response body: \(bodyString)")
                //            log.info("Description: \(response.description)")
            } else {
                log.error("Failed to send message to Telegram API server")
                log.error("- API token: \(telegramAPIToken)")
                log.error("- API URI: \(telegramURI)")
                log.error("- Client API URL: \(client.tgAPIURI)")
                log.error("- Request HTTP status: \(response.status)")
                log.error("- Response body: \(bodyString)")
                //            log.error("- Description: \(response.description)")
            }
            try await Task.sleep(nanoseconds: 500000000)
        }
    }

    func error(_ context: QueueContext, _ error: Error, _ payload: TGMessagesToSend) async throws {
        let log = context.logger
        log.error("Error sending queued message to: \(String(payload.messageReceiverID))")
        log.error("Queue error message: \(error)")
    }
}
