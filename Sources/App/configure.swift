//
//

import Vapor
import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Queues
import QueuesFluentDriver
import LingoVapor

// configures your application
public func configure(_ app: Application) async throws {
//    guard let telegramAPIToken = Environment.get("TELEGRAM_API_TOKEN") else {
    guard let _ = Environment.get("TELEGRAM_API_TOKEN") else {
        throw BotConfigError.missingTelegramAPIToken("ERROR: missing Telegram API Token in environment")
    }
//    guard let telegramURI = Environment.get("TELEGRAM_URI") else {
    guard let _ = Environment.get("TELEGRAM_URI") else {
        throw BotConfigError.missingTelegramURI("ERROR: missing Telegram URI in environment")
    }
//    guard let testListenPort = Environment.get("TEST_LISTEN_PORT") else {
    guard let _ = Environment.get("TEST_LISTEN_PORT") else {
        throw BotConfigError.missingTestListenPort("ERROR: missing Test Listen Port in environment")
    }

    app.lingoVapor.configuration =
        .init(defaultLocale: "en",
              localizationsDir: "Localizations")
    let lingo = try app.lingoVapor.lingo()

    // register routes
    try app.register(collection: BasicRoutesController())
    try app.register(collection: GreetzBotController(lingo))

    // set up queues
    if app.environment == .testing {
        app.queues.use(.spy)
    } else {
        app.databases.use(.postgres(configuration: SQLPostgresConfiguration(
            hostname: Environment.get("PGHOST") ?? "localhost",
            port: Environment.get("PGPORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
            username: Environment.get("PGUSER") ?? "vapor_username",
            password: Environment.get("PGPASS") ?? "vapor_password",
            database: Environment.get("PGDATABASE") ?? "vapor_database",
            tls: .disable)
        ), as: .psql)
        // for vapor-queues-fluent-driver
        app.migrations.add(JobMetadataMigrate())
        try await app.autoMigrate()
        app.queues.use(.fluent())
    }
    let sendMessageJob = SendTelegramAPIMessageJob()
    app.queues.add(sendMessageJob)

    if app.environment != .testing {
        try app.queues.startInProcessJobs(on: .default)
        try app.queues.startScheduledJobs()
    }


    // listen port; default is 8100/TCP
    app.http.server.configuration.port
    = Environment.get("LISTEN_PORT").flatMap(Int.init(_:)) ?? 8100
}
