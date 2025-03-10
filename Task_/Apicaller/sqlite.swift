import SQLite3
import Foundation

final class DatabaseHelper {
    private var db: OpaquePointer?
    static let shared = DatabaseHelper()

    private init() {
        openDatabase()
    }

    // MARK: - Open Database
    func openDatabase() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = documentsDirectory.appendingPathComponent("hmBetaLogin.sqlite").path

        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened database at \(dbPath)")
            createTable()
        } else {
            print("Failed to open database: \(String(cString: sqlite3_errmsg(db)))")
        }
    }

    // MARK: - Create Table
    func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            first_name TEXT,
            last_name TEXT,
            gender TEXT,
            date_of_birth TEXT,
            height REAL
        );
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print(" Table created successfully")
            } else {
                print(" Failed to create table: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print(" Failed to prepare table creation statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        sqlite3_finalize(statement)
    }

    // MARK: - Check If User Exists (Prevent Duplicate Emails)
    func isUserExists(email: String) -> Bool {
        let query = "SELECT email FROM Users WHERE email = ?;"
        var statement: OpaquePointer?
        var exists = false
        let email = email.cString(using: .utf8)
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, email, -1, nil)

            if sqlite3_step(statement) == SQLITE_ROW {
                exists = true
            }
        } else {
            print(" Failed to prepare user check statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        sqlite3_finalize(statement)
        return exists
    }

    // MARK: - Insert or Update User
    func insertOrUpdateUser(email: String, password: String, firstName: String, lastName: String, gender: String, dateOfBirth: String, height: Double) -> Bool {
        if isUserExists(email: email) {
            print(" User with email \(email) already exists. Updating details...")
            let success = updateUser(email: email, firstName: firstName, lastName: lastName, gender: gender, dateOfBirth: dateOfBirth, height: height)
            if success {
                print(" User updated successfully: \(email)")
            } else {
                print(" Failed to update user")
            }
            return success
        }

        let insertQuery = """
            INSERT INTO Users (email, password, first_name, last_name, gender, date_of_birth, height) 
            VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        //
        var statement: OpaquePointer?
        var success = false
        let email = email.cString(using: .utf8)
        let firstName = firstName.cString(using: .utf8)
        let lastName = lastName.cString(using: .utf8)
        let dateOfBirth = dateOfBirth.cString(using: .utf8)
        let gender = gender.cString(using: .utf8)
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, email, -1, nil)
            sqlite3_bind_text(statement, 2, password, -1, nil)
            sqlite3_bind_text(statement, 3, firstName, -1, nil)
            sqlite3_bind_text(statement, 4, lastName, -1, nil)
            sqlite3_bind_text(statement, 5, gender, -1, nil)
            sqlite3_bind_text(statement, 6, dateOfBirth, -1, nil)
            sqlite3_bind_double(statement, 7, height)

            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
              
            } else {
                print(" Failed to insert user: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print(" Failed to prepare insert statement: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return success
    }

    // MARK: - Fetch User
    func fetchUser(byEmail email: String) -> UserModel? {
        let query = "SELECT email, first_name, last_name, gender, date_of_birth, height FROM Users WHERE email = ?;"
        var statement: OpaquePointer?
        var user: UserModel?
        let email = email.cString(using: .utf8)
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, email, -1, nil)
                
            if sqlite3_step(statement) == SQLITE_ROW {
                let email = String(cString: sqlite3_column_text(statement, 0))
                let firstName = String(cString: sqlite3_column_text(statement, 1))
                let lastName = String(cString: sqlite3_column_text(statement, 2))
                let gender = String(cString: sqlite3_column_text(statement, 3))
                let dateOfBirth = String(cString: sqlite3_column_text(statement, 4))
                let height = sqlite3_column_double(statement, 5)
                print(email,firstName,lastName,gender,dateOfBirth,height,"dhvufgug")
                user = UserModel(
                    userName: email,
                    password: "", // For security, password is not fetched
                    softwareType: "AN",
                    releaseVersion: "049",
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    gender: gender,
                    dateOfBirth: dateOfBirth,
                    height: height
                )
            }
        } else {
            print(" Failed to prepare fetch user statement: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return user
    }

    // MARK: - Update User
    func updateUser(email: String, firstName: String, lastName: String, gender: String, dateOfBirth: String, height: Double) -> Bool {
        let updateQuery = """
            UPDATE Users SET first_name = ?, last_name = ?, gender = ?, date_of_birth = ?, height = ? WHERE email = ?;
        """
        
        var statement: OpaquePointer?
        var success = false
        let email = email.cString(using: .utf8)
        let firstName = firstName.cString(using: .utf8)
        let lastName = lastName.cString(using: .utf8)
        let dateOfBirth = dateOfBirth.cString(using: .utf8)
        let gender = gender.cString(using: .utf8)
        if sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, firstName, -1, nil)
            sqlite3_bind_text(statement, 2, lastName, -1, nil)
            sqlite3_bind_text(statement, 3, gender, -1, nil)
            sqlite3_bind_text(statement, 4, dateOfBirth, -1, nil)
            sqlite3_bind_double(statement, 5, height)
            sqlite3_bind_text(statement, 6, email, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                print(" Failed to update user: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print(" Failed to prepare update statement: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return success
    }
}
