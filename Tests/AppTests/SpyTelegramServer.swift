//
//

import Vapor
@testable import App

final class SpyTelegramServer {
    var testApp: Application!
    var testUpdateID: Int64 = 11223344
    var apiRequestList: [String] = []
    var requestBodyText: [String] = []

    public func generateSpyTelegramAPIServer(_ listenPort: String = "43210") -> Application {
        let fakeTelegramEnv = Environment(
            name: "testing",
            arguments: ["vapor", "serve", "--port", listenPort]
        )
        let fakeTelegramApp = Application(fakeTelegramEnv)
        fakeTelegramApp.logger.logLevel = .debug
        return fakeTelegramApp
    }

    public func returnsSendMessageResponse(_ req: Request) throws -> TGResponseSendMessage {
        let sendMessage = try req.content.decode(TGSendMessage.self)
        let sendMsgResponse = TGTestMsgGenerator(userID: sendMessage.chat_id)
            .generateSendMessageResponse(successful: true,
                                         text: sendMessage.text)
        apiRequestList.append("returnsSendMessageResponse - chat_id: \(String(sendMessage.chat_id))")
        requestBodyText.append(sendMessage.text)
        return sendMsgResponse
    }

    // MARK: Helper methods
    private func generateISO8601Date(date: Date = Date()) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }

    private func generateCurrentUNIXEpoch(date: Date = Date()) -> String {
        return "\(Int(Date().timeIntervalSince1970))"
    }
}
