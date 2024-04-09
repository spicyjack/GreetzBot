@testable import App
import XCTVapor

final class BasicRoutesControllerTests: XCTestCase {
    var testApp: Application!

    override func setUp() async throws {
        testApp = try await Application.vaporTestSetup()
    }

    override func tearDown() async throws {
        testApp.shutdown()
    }

    func test_GET_empty() async throws {
        try testApp.test(.GET, "", afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        })
    }

    func test_GET_hello() async throws {
        try testApp.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }

    func test_GET_foo() async throws {
        try testApp.test(.GET, "foo", afterResponse: { res in
            XCTAssertEqual(res.status, .gone)
        })
    }
}
