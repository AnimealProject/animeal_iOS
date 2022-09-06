// System
import Foundation

// SDK
import Services
import Common

final class PhoneAuthModel: PhoneAuthModelProtocol {
    // MARK: - Constants
    private enum Constants {
        static let phoneNumberPrefix = "+995"
        static let maxDigitsNumber = 12
    }

    // MARK: - Private properties
    private var items: [PhoneAuthModelItem]

    private var phone: String? {
        guard let phoneNumber = items.first(where: { $0.type == .phone })?.text
        else { return nil }
        return Constants.phoneNumberPrefix + phoneNumber
    }

    private var password: String? { items.first(where: { $0.type == .password })?.text }

    private lazy var operationQueue = OperationQueue()

    // MARK: - Dependencies
    private let authenticationService: AuthenticationServiceProtocol

    // MARK: - Responses
    var fetchItemsResponse: (([PhoneAuthModelItem]) -> Void)?

    // MARK: - Initializations
    init(authenticationService: AuthenticationServiceProtocol) {
        self.authenticationService = authenticationService
        self.items = [
            PhoneAuthModelItem(
                identifier: UUID().uuidString,
                type: PhoneAuthItemType.phone,
                style: PhoneAuthItemStyle.editable,
                state: PhoneAuthItemState.normal,
                text: nil
            ),
            PhoneAuthModelItem(
                identifier: UUID().uuidString,
                type: PhoneAuthItemType.password,
                style: PhoneAuthItemStyle.editable,
                state: PhoneAuthItemState.normal,
                text: nil
            )
        ]
    }

    // MARK: - Requests
    func fetchItems() {
        fetchItemsResponse?(items)
    }

    func fetchItem(_ identifier: String) -> PhoneAuthModelItem? {
        guard
            let item = items.first(where: { $0.identifier == identifier })
        else { return nil }
        return item
    }

    func updateItem(_ text: String?, forIdentifier identifier: String) {
        guard
            let itemIndex = items.firstIndex(where: { $0.identifier == identifier })
        else { return }
        items[itemIndex].text = text
    }

    func proceedAuthentication() async throws -> PhoneAuthModelNextStep {
        guard let phone = phone, let password = password else {
            throw PhoneAuthValidationError.empty
        }

        do {
            let signUpResult = try await authenticationService.signUp(
                username: phone,
                password: password,
                options: [AuthenticationUserAttribute(.phoneNumber, value: phone)]
            )
            return PhoneAuthModelNextStep.afterSignUp(signUpResult)
        } catch AuthenticationError.service(_, _, let error)
                    where (error as? AuthenticationDetailedError) == .usernameExists {
            let signInResult = try await authenticationService.signIn(username: phone)
            return PhoneAuthModelNextStep.afterSignIn(signInResult)
        } catch {
            throw error
        }
    }

    func validateItems() -> Bool {
        do {
            try validate()
            let validatingItems = items
            items = validatingItems.map {
                PhoneAuthModelItem(
                    identifier: $0.identifier,
                    type: $0.type,
                    style: $0.style,
                    state: PhoneAuthItemState.normal,
                    text: $0.text
                )
            }
            fetchItemsResponse?(items)
            return true
        } catch {
            let description = error.localizedDescription
            let validatingItems = items
            items = validatingItems.map {
                PhoneAuthModelItem(
                    identifier: $0.identifier,
                    type: $0.type,
                    style: $0.style,
                    state: PhoneAuthItemState.error(description),
                    text: $0.text
                )
            }
            fetchItemsResponse?(items)
            return false
        }
    }

    private func validate() throws {
        guard
            let phone = phone, !phone.isEmpty,
            let password = password, !password.isEmpty
        else {
            throw PhoneAuthValidationError.empty
        }

        if phone.replacingOccurrences(of: "+", with: "").count != Constants.maxDigitsNumber {
            throw PhoneAuthValidationError.incorrectPhoneNumber
        }
    }
}

private extension PhoneAuthModelNextStep {
    static func afterSignUp(_ result: AuthenticationSignUpState) -> Self {
        switch result.nextStep {
        case .confirmUser(let details, _):
            return PhoneAuthModelNextStep.confirm(details?.destination ?? .unknown(nil))
        case .done:
            return PhoneAuthModelNextStep.done
        }
    }
    
    static func afterSignIn(_ result: AuthenticationSignInState) -> Self {
        switch result.nextStep {
        case .confirmSignInWithSMSCode(let details, _):
            return PhoneAuthModelNextStep.confirm(details.destination)
        case .resetPassword:
            return PhoneAuthModelNextStep.resetPassword
        case .done:
            return PhoneAuthModelNextStep.done
        case .confirmSignInWithNewPassword:
            return PhoneAuthModelNextStep.setNewPassword
        default:
            return PhoneAuthModelNextStep.unknown
        }
    }
}
