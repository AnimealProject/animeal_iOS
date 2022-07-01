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
    func setUserFirstName(_ name: String)
    func setUserLastName(_ name: String)
    func setUserEmail(_ email: String)
    func setUserBirthDate(_ date: Date)
}

protocol StringProcessable {
    func process(_ string: String) -> String
}
