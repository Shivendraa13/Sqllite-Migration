//
//  DatabaseManager.swift
//  testProject
//
//  Created by Apple on 20/12/24.
//

import SQLite3
import Foundation

class DatabaseManager {
    var db: OpaquePointer?
    
    init() {
        if sqlite3_open(dbPath(), &db) != SQLITE_OK {
            print("Error opening database")
        } else {
            setupMigrations()
        }
    }
    
    func dbPath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return path + "/my_database.sqlite"
    }
    
    // MARK: - Migration Setup
    func setupMigrations() {
        createMigrationTable()
        applyPendingMigrations()
    }
    
    private func createMigrationTable() {
        let query = """
        CREATE TABLE IF NOT EXISTS migrations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            version TEXT UNIQUE
        );
        """
        if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
            print("Error creating migrations table")
        }
    }
    
//    private func applyPendingMigrations() {
//        let migrations: [String: () -> Void] = [
//            "1.0": migrateToVersion1,
//            "2.0": migrateToVersion2,
//            "3.0": migrateToVersion3
//        ]
//        
//        let appliedVersions = fetchAppliedMigrations()
//        for (version, migration) in migrations {
//            if !appliedVersions.contains(version) {
//                migration()
//                markMigrationApplied(version: version)
//            }
//        }
//    }
    
    private func applyPendingMigrations() {
        let migrations: [(String, () -> Void)] = [
            ("1.0", migrateToVersion1),
            ("2.0", migrateToVersion2),
            ("3.0", migrateToVersion3)
        ]
        
        let appliedVersions = fetchAppliedMigrations()
        for (version, migration) in migrations {
            if !appliedVersions.contains(version) {
                migration()
                markMigrationApplied(version: version)
            }
        }
    }

    
    private func fetchAppliedMigrations() -> Set<String> {
        let query = "SELECT version FROM migrations;"
        var statement: OpaquePointer?
        var versions = Set<String>()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let version = String(cString: sqlite3_column_text(statement, 0))
                versions.insert(version)
            }
        }
        
        sqlite3_finalize(statement)
        return versions
    }
    
    private func markMigrationApplied(version: String) {
        let query = "INSERT INTO migrations (version) VALUES (?);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (version as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to record migration \(version)")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - Migrations
    private func migrateToVersion1() {
        print("Applying migration 1.0: Initial table setup")
        let query = """
        CREATE TABLE IF NOT EXISTS items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT
        );
        """
        if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
            print("Error applying migration 1.0")
        }
    }
    
    private func migrateToVersion2() {
        print("Applying migration 2.0: Adding new columns")
        let columns = ["email", "phone", "service", "add1", "add2", "add3"]
        for column in columns {
            let query = "ALTER TABLE items ADD COLUMN \(column) TEXT;"
            if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
                print("Error adding column \(column)")
            } else {
                print("Column \(column) added successfully")
            }
        }
    }
    
    private func migrateToVersion3() {
        print("Applying migration 3.0: Adding new columns")
        let columns = ["add4"]
        for column in columns {
            let query = "ALTER TABLE items ADD COLUMN \(column) TEXT;"
            if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
                print("Error adding column \(column)")
            } else {
                print("Column \(column) added successfully")
            }
        }
    }
    
    // MARK: - CRUD Operations
    func insertData(title: String, description: String, email: String, phone: String, service: String, add1: String, add2: String, add3: String) {
        let query = """
        INSERT INTO items (title, description, email, phone, service, add1, add2, add3, add4)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (description as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (service as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (add1 as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 7, (add2 as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 8, (add3 as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 9, ("add4" as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Failed to insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(statement)
    }
    
    func fetchData() -> [(Int, String, String, String, String, String, String, String, String)] {
        let query = "SELECT * FROM items;"
        var statement: OpaquePointer?
        var results: [(Int, String, String, String, String, String, String, String, String)] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let title = String(cString: sqlite3_column_text(statement, 1))
                let description = String(cString: sqlite3_column_text(statement, 2))
                let email = String(cString: sqlite3_column_text(statement, 3))
                let phone = String(cString: sqlite3_column_text(statement, 4))
                let service = String(cString: sqlite3_column_text(statement, 5))
                let add1 = String(cString: sqlite3_column_text(statement, 6))
                let add2 = String(cString: sqlite3_column_text(statement, 7))
                let add3 = String(cString: sqlite3_column_text(statement, 8))
                let add4 = sqlite3_column_text(statement, 9) != nil
                                ? String(cString: sqlite3_column_text(statement, 9))
                                : ""
                
                print("print \(add4)")
                results.append((Int(id), title, description, email, phone, service, add1, add2, add3))
            }
        }
        
        sqlite3_finalize(statement)
        return results
    }
    
    func close() {
        sqlite3_close(db)
    }
}


