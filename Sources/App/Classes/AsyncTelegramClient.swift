//  
//

import Vapor

enum AsyncClientError: Error {
    case missingMessageMethod
    case missingMessageIDForEditMessageText
}

class AsyncTelegramClient: AsyncTelegramRequestable {
    let client: Client
    let apiToken: String
    let apiServer: String
    let tgAPIURI: String

    public init(client: Client,
                apiToken: String,
                apiServer: String = "https://api.telegram.org/bot"
    ) {
        self.client = client
        self.apiToken = apiToken
        self.apiServer = apiServer
        self.tgAPIURI = self.apiServer + self.apiToken + "/"
    }

    // FIXME: @moping use generics here to create a generic send() method
    func sendRequest(_ msg: TGUpdateReply) async throws -> ClientResponse {
        var msgToSend: any TGAPISendable
        switch msg.method {
        case "sendMessage":
            msgToSend = TGSendMessage(
                chat_id: msg.chat_id,
                parse_mode: msg.parse_mode,
                text: msg.text,
                reply_markup: msg.reply_markup)
        default:
            throw AsyncClientError.missingMessageMethod
        }
        let encoder = JSONEncoder()
        let data = try encoder.encode(msgToSend)
        print("==> Sending: " + String(data: data, encoding: .utf8)!)

        let sendMessageURI = self.tgAPIURI + msg.method
        let apiURI = URI(stringLiteral: sendMessageURI)
        return try await client.post(apiURI, content: msgToSend)
    }

    func sendMessage(_ msg: TGSendMessage) async throws -> ClientResponse {
        let sendMessageURI = self.tgAPIURI + "sendMessage"
        let apiURI = URI(stringLiteral: sendMessageURI)
        let encoder = JSONEncoder()
        let data = try encoder.encode(msg)
        print("==> Sending: " + String(data: data, encoding: .utf8)!)
        return try await client.post(apiURI, content: msg)
    }
}
