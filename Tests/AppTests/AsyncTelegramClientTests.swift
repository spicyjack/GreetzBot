//
//

import XCTVapor
@testable import App

struct TestHTTPBinResponse: Content {
    var headers: [String: String]
    var json: TGSendMessage
    var method: String
    var origin: String
    var url: String
}

class AsyncTelegramClientTests: XCTestCase {
    private var testApp: Application!
    private var testClient: AsyncTelegramRequestable!
    private var testListenPort: String!
    private var testTelegramAPIToken: String!
    private var testTelegramURI: String!

    private let testDefaultFromID: Int64 = 10203040506

    override func setUp() async throws {
        testApp = try await Application.vaporTestSetup()
        testTelegramAPIToken = try XCTUnwrap(Environment.get("TELEGRAM_API_TOKEN"))
        testTelegramURI = try XCTUnwrap(Environment.get("TELEGRAM_URI"))
        testListenPort = try XCTUnwrap(Environment.get("TEST_LISTEN_PORT"))
        testClient = AsyncTelegramClient(client: testApp.client,
                                         apiToken: testTelegramAPIToken,
                                         apiServer: testTelegramURI)
    }

    override func tearDown() async throws {
        testApp.shutdown()
    }

    func test_sendRequestWithSendMessage_successfulTelegramAPIResponse() async throws {
        let testMsgText = "This is a private message"
        let testSendMessage = TGTestMsgGenerator(userID: testDefaultFromID)
            .generatePrivateReplyMsg(method: "sendMessage",
                                     text: testMsgText)

        let spyTGAPIServer = SpyTelegramServer()
        let fakeTGApp = spyTGAPIServer.generateSpyTelegramAPIServer(testListenPort)
        defer { fakeTGApp.shutdown() }

        fakeTGApp.post("bot\(testTelegramAPIToken!)", "sendMessage") { req in
            return try spyTGAPIServer.returnsSendMessageResponse(req)
        }
        try await fakeTGApp.startup()

        let response = try await testClient.sendRequest(testSendMessage)
        dump("Response: \(response)")
        let sendMessageResponse = try response.content.decode(TGResponseSendMessage.self)
        let testSendMessageResponse = try XCTUnwrap(sendMessageResponse.result)
        XCTAssertTrue(sendMessageResponse.ok)
        XCTAssertEqual(response.status, HTTPStatus.ok)
        XCTAssertEqual(testSendMessage.chat_id, testSendMessageResponse.chat_id)
        XCTAssertEqual(testSendMessage.text, testSendMessageResponse.text)
        let spyAPIRequestList = spyTGAPIServer.apiRequestList
        XCTAssertEqual(spyAPIRequestList.count, 1)
        let apiMsgCheckList: [String] = [
            "returnsSendMessageResponse - chat_id: \(testDefaultFromID)"
        ]
        for idx in 0 ... (apiMsgCheckList.count - 1) {
            XCTAssertEqual(spyAPIRequestList[idx], apiMsgCheckList[idx])
        }
    }


    func test_sendMessage_successfulTelegramAPIResponse() async throws {
        let testMsgText = "This is a private message"
        let testSendMessage = TGTestMsgGenerator(userID: testDefaultFromID)
            .generatePrivateReplyMsg(method: "sendMessage",
                                     text: testMsgText)
        let spyTGAPIServer = SpyTelegramServer()
        let fakeTGApp = spyTGAPIServer.generateSpyTelegramAPIServer(testListenPort)
        defer { fakeTGApp.shutdown() }

        fakeTGApp.post("bot\(testTelegramAPIToken!)", "sendMessage") { req in
            return try spyTGAPIServer.returnsSendMessageResponse(req)
        }
        try await fakeTGApp.startup()

        let response = try await testClient.sendRequest(testSendMessage)
        let sendMessageResponse = try response.content.decode(TGResponseSendMessage.self)
        let testSendMessageResponse = try XCTUnwrap(sendMessageResponse.result)
        XCTAssertTrue(sendMessageResponse.ok)
        XCTAssertEqual(response.status, HTTPStatus.ok)
        XCTAssertEqual(testSendMessage.chat_id, testSendMessageResponse.chat_id)
        XCTAssertEqual(testSendMessage.text, testSendMessageResponse.text)
        let spyAPIRequestList = spyTGAPIServer.apiRequestList
        XCTAssertEqual(spyAPIRequestList.count, 1)
        let apiMsgCheckList: [String] = [
            "returnsSendMessageResponse - chat_id: \(testDefaultFromID)"
        ]
        for idx in 0 ... (apiMsgCheckList.count - 1) {
            XCTAssertEqual(spyAPIRequestList[idx], apiMsgCheckList[idx])
        }
    }
}
