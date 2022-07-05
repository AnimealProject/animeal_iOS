import Foundation

final class ProfileModel: ProfileModelProtocol {

    // MARK: - Public methods
    func getUserFirstName() -> String {
        // Services are not implemented yet
        "Michelangelo"
    }

    func setUserFirstName(_ name: String) {
        // Services are not implemented yet
    }

    func getUserLastName() -> String {
        // Services are not implemented yet
        "Buonarotti"
    }

    func setUserLastName(_ name: String) {
        // Services are not implemented yet
    }

    func getUserEmail() -> String {
        // Services are not implemented yet
        "b_michelangelo@gmail.com"
    }

    func setUserEmail(_ email: String) {
        // Services are not implemented yet
    }

    func getUserBirthDate() -> Date {
        // Services are not implemented yet
        var dateComponents = DateComponents()
        dateComponents.year = 2000
        dateComponents.month = 7
        dateComponents.day = 1
        return Calendar.current.date(from: dateComponents) ?? Date()
    }

    func setUserBirthDate(_ date: Date) {
        // Services are not implemented yet
    }

    func getUserPhoneNumber() -> String {
        // Services are not implemented yet
        "995558499969"
    }
}
