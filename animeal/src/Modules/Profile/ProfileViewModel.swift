import Foundation
import UIComponents
import Common

final class ProfileViewModel: ProfileViewModelProtocol {

    // MARK: - Dependencies
    private let model: ProfileModelProtocol
    private let stringProcessor: StringProcessable
    private let dateFormatter: DateFormatter

    private var userPhoneNumber: String {
        model.getUserPhoneNumber()
    }

    // MARK: - Public properties
    var userFirstName: String {
        get {
            model.getUserFirstName()
        }
        set {
            model.setUserFirstName(newValue)
        }
    }

    var userLastName: String {
        get {
            model.getUserLastName()
        }
        set {
            model.setUserLastName(newValue)
        }
    }

    var userEmail: String {
        get {
            model.getUserEmail()
        }
        set {
            model.setUserEmail(newValue)
        }
    }

    var processedPhoneNumber: String {
        stringProcessor.process(userPhoneNumber)
    }

    var formattedBirthdate: String {
        dateFormatter.string(from: model.getUserBirthDate())
    }

    // MARK: - Initialization
    init(
        model: ProfileModelProtocol,
        stringProcessor: StringProcessable,
        dateFormatter: DateFormatter
    ) {
        self.model = model
        self.stringProcessor = stringProcessor
        self.dateFormatter = dateFormatter
    }

    // MARK: - Public methods
    func setUserBirthdate(_ date: Date, completion: ((String) -> Void)?) {
        model.setUserBirthDate(date)
        completion?(dateFormatter.string(from: date))
    }

    func onDoneButtonDidTap() {
        // Navigation is not implemented yet
    }
}
