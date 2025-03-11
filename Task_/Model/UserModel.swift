import Foundation

struct UserModel: Codable {
    let userName: String
    let password: String
    let softwareType: String
    let releaseVersion: String
    var email: String
    var firstName: String
    var lastName: String
    var gender: String
    var dateOfBirth: String
    var height: Double

    // ✅ Full initializer with all parameters
    init(userName: String, password: String, softwareType: String, releaseVersion: String, email: String, firstName: String, lastName: String, gender: String, dateOfBirth: String, height: Double) {
        self.userName = userName
        self.password = password
        self.softwareType = softwareType
        self.releaseVersion = releaseVersion
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.height = height
    }
}
