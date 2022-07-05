import Foundation

// MARK: - View
protocol ProfileViewModelOutput: AnyObject {
}

// MARK: - ViewModel
protocol ProfileViewModelProtocol {
    var userFirstName: String { get set }
    var userLastName: String { get set }
    var userEmail: String { get set }
    var processedPhoneNumber: String { get }
    var formattedBirthdate: String { get }

    func setUserBirthdate(_ date: Date, completion: ((String) -> Void)?)
    func onDoneButtonDidTap()
}

// MARK: - Model
protocol ProfileModelProtocol {
    func getUserFirstName() -> String
    func setUserFirstName(_ name: String)
    func getUserLastName() -> String
    func setUserLastName(_ name: String)
    func getUserEmail() -> String
    func setUserEmail(_ email: String)
    func getUserBirthDate() -> Date
    func setUserBirthDate(_ date: Date)
    func getUserPhoneNumber() -> String
}
