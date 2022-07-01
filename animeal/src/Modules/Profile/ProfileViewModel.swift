import Foundation
import UIComponents

final class ProfileViewModel: ProfileViewModelProtocol {

    // MARK: - Dependencies
    private let model: ProfileModelProtocol
    private let stringProcessor: StringProcessable
    private let dateFormatter: DateFormatter

    // MARK: - Mock
    private var userBirthdate: Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2000
        dateComponents.month = 7
        dateComponents.day = 1
        return Calendar.current.date(from: dateComponents) ?? Date()
    }

    private var userPhoneNumber: String {
        "995558499969"
    }

    // MARK: - Public properties
    var userFirstName: String {
        get {
            // Services are not implemented yet
            "Michelangelo"
        }
        set {
            model.setUserFirstName(newValue)
        }
    }

    var userLastName: String {
        get {
            // Services are not implemented yet
            "Buonarotti"
        }
        set {
            model.setUserLastName(newValue)
        }
    }

    var userEmail: String {
        get {
            // Services are not implemented yet
            "b_michelangelo@gmail.com"
        }
        set {
            model.setUserEmail(newValue)
        }
    }

    var processedPhoneNumber: String {
        stringProcessor.process(userPhoneNumber)
    }

    var formattedBirthdate: String {
        dateFormatter.string(from: userBirthdate)
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
