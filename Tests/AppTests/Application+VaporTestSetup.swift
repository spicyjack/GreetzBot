//
//

import XCTVapor
import App

extension Application {
    static func vaporTestSetup() async throws -> Application {
        let app = Application(.testing)
        try await configure(app)
        return app
    }
}

