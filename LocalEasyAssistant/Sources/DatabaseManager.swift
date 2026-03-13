import Foundation
import GRDB

struct Message: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var content: String
    var isUser: Bool
    var timestamp: Date
}

class DatabaseManager {
    static let shared = DatabaseManager()
    let dbQueue: DatabaseQueue

    init() {
        let databaseURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        
        dbQueue = try! DatabaseQueue(path: databaseURL.path)
        
        try! dbQueue.write { db in
            try db.create(table: "message", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("content", .text).notNull()
                t.column("isUser", .boolean).notNull()
                t.column("timestamp", .datetime).notNull()
            }
        }
    }

    func saveMessage(_ message: Message) throws {
        try dbQueue.write { db in
            var message = message
            try message.insert(db)
        }
    }

    func fetchMessages() throws -> [Message] {
        try dbQueue.read { db in
            try Message.order(Column("timestamp").asc).fetchAll(db)
        }
    }
    
    func clearHistory() throws {
        try dbQueue.write { db in
            try Message.deleteAll(db)
        }
    }
}
