@testable import App
import XCTVapor

final class GreetzBotControllerTests: XCTestCase {
    var testApp: Application!
    var testListenPort: String!
    var telegramAPIToken: String!
    var spyTGAPIServer: SpyTelegramServer!

    override func setUp() async throws {
        testApp = try await Application.vaporTestSetup()
        testListenPort = try XCTUnwrap(Environment.get("TEST_LISTEN_PORT"))
        telegramAPIToken = try XCTUnwrap(Environment.get("TELEGRAM_API_TOKEN"))
        spyTGAPIServer = SpyTelegramServer()
    }

    override func tearDown() async throws {
        testApp.shutdown()
    }

    func test_POST_webroot_withTextBlock_shouldReturnTextBlockWithEscapedMarkup() async throws {
        let testChatID: Int64 = 1199228833
        let testText = "*bold* _italic_ __underline__ ~strikethrough~ ||spoiler||"
        let testReplyText = "Greetz! \\*bold\\* \\_italic\\_ \\_\\_underline\\_\\_ "
            + "\\~strikethrough\\~ \\|\\|spoiler\\|\\|"
        let queueMessageCount = 1

        try await runAndAssertRequestWithQueuedMessage(
            testChatID: testChatID,
            testText: testText,
            testReplyText: testReplyText,
            testQueueCount: queueMessageCount)
    }

    private func runAndAssertRequestWithQueuedMessage(
        testURLPath: String = "",
        testChatID: Int64,
        testText: String,
        testReplyText: String,
        testQueueCount: Int
    ) async throws {
        var queueMessageCount = testQueueCount
        let fakeTGApp = spyTGAPIServer.generateSpyTelegramAPIServer(testListenPort)
        defer { fakeTGApp.shutdown() }
        fakeTGApp.post("bot\(telegramAPIToken!)", "sendMessage") { req in
            return try self.spyTGAPIServer.returnsSendMessageResponse(req)
        }
        try await fakeTGApp.startup()

        let updateMsg = TGTestMsgGenerator(userID: testChatID)
            .generatePrivateMessage(testText)
        let spyAPICheck = "returnsSendMessageResponse - chat_id: \(testChatID)"

        try testApp.test(.POST, testURLPath, beforeRequest: { req in
            try req.content.encode(updateMsg)
        }, afterResponse: { resp in
            XCTAssertEqual(resp.status, .ok)
        })

        while queueMessageCount > 0 {
            XCTAssertEqual(testApp.queues.spy.queue.count, queueMessageCount)
            XCTAssertEqual(testApp.queues.spy.jobs.count, queueMessageCount)
            try await testApp.queues.queue.worker.run().get()
            queueMessageCount -= 1
        }

        XCTAssertEqual(testReplyText, spyTGAPIServer.requestBodyText.first)
        XCTAssertEqual(spyAPICheck, spyTGAPIServer.apiRequestList.first)

    }
}
