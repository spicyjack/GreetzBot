//
//

import Vapor

protocol AsyncTelegramRequestable {
    typealias Result = Swift.Result<ClientResponse, Error>

    func sendRequest(_ msg: TGUpdateReply) async throws -> ClientResponse
    func sendMessage(_ msg: TGSendMessage) async throws -> ClientResponse
}
