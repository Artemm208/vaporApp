import Vapor
import FluentMySQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    print("test print")
    print("isLinuxEnvironment: \(isLinuxEnvironment(env: env))")
    
    /// Register providers first
     try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
     var middlewares = MiddlewareConfig() // Create _empty_ middleware config
     middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
     middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
     services.register(middlewares)
    
    var databases = DatabasesConfig()
    // Configure a MySQL database
    var databaseName: String
    var databasePort: Int
    let databaseHost = host(env: env)
    
    if (env == .testing) {
        databaseName = "test"
        databasePort = 3306
    } else {
        databaseName = Environment.get("MYSQL_DATABASE") ?? "test"
        databasePort = 3306
    }
    
    let databaseConfig = MySQLDatabaseConfig(
        hostname: databaseHost,
        port: databasePort,
        username: "root",
        password: "password",
        database: databaseName)
    let database = MySQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Acronym.self, database: .mysql)
    migrations.add(model: Category.self, database: .mysql)
    migrations.add(model: AcronymCategoryPivot.self, database: .mysql)
    services.register(migrations)
    
    //register fluent commands
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}

fileprivate func host(env: Environment) -> String {
    return isLinuxEnvironment(env: env) ? "db" : "localhost"
}

fileprivate func isLinuxEnvironment(env: Environment) -> Bool {
    
    for envItem in env.arguments {
        if  envItem.contains("linux") {
            return true
        }
    }
    return false
}
