//  
//

import Vapor
import Fluent

struct BasicRoutesController: RouteCollection {
    func boot(routes:RoutesBuilder) throws {
        routes.get("", use: empty)
        routes.get("hello", use: hello)
        routes.get("**", use: catchAll)
    }

    func empty(_ req: Request) throws -> HTTPStatus {
        return .noContent
    }

    func hello(_ req: Request) throws -> String {
        return "Hello, world!"
    }

    func catchAll(_ req: Request) throws -> HTTPStatus {
        return .gone
    }
}

