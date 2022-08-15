// System
import Foundation

// SDK
import Services
import Common

final class PhoneAuthModel: PhoneAuthModelProtocol {
    // MARK: - Constants
    private enum Constants {
        static let phoneNumberPrefix = "+995"
        static let maxDigitsNumber = 9
    }

    // MARK: - Private properties
    private var items: [PhoneAuthModelItem]

    private var phone: String? {
        guard let phoneNumber = items.first(where: { $0.type == .phone })?.text
        else { return nil }
        return Constants.phoneNumberPrefix + phoneNumber
    }

    private var password: String? {
        items.first(where: { $0.type == .password })?.text
    }

    private lazy var operationQueue = OperationQueue()

    // MARK: - Dependencies
    private let authenticationService: AuthenticationServiceProtocol

    // MARK: - Responses
    var fetchItemsResponse: (([PhoneAuthModelItem]) -> Void)?
    var proceedAuthenticationResponse: ((Result<PhoneAuthModelNextStep, Error>) -> Void)?

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

    func proceedAuthentication() {
        guard let phone = phone, let password = password else {
            return
        }

        let signUpOperation = PhoneAuthSignUpOperation(
            authenticationService: authenticationService,
            phone: phone,
            passwword: password
        )
        let signInOperation = PhoneAuthSignInOperation(
            authenticationService: authenticationService,
            phone: phone,
            passwword: password
        )
        signInOperation.dataStore = signUpOperation
        signInOperation.addDependency(signUpOperation)
        signInOperation.authenticationHandler = { [weak self] result in
            self?.proceedAuthenticationResponse?(result.mapError { $0 as Error })
        }

        operationQueue.addOperation(signUpOperation)
        operationQueue.addOperation(signInOperation)
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

        if phone.count != Constants.maxDigitsNumber {
            throw PhoneAuthValidationError.incorrectPhoneNumber
        }
    }
}

protocol PhoneAuthSignInDataStore: AnyObject {
    var result: Result<AuthenticationSignUpState, AuthenticationError>? { get }
}

private extension PhoneAuthModel {

    final class PhoneAuthSignUpOperation: AsyncOperation, PhoneAuthSignInDataStore {
        private let authenticationService: AuthenticationServiceProtocol
        private let phone: String
        private let password: String

        var result: Result<AuthenticationSignUpState, AuthenticationError>?

        init(
            authenticationService: AuthenticationServiceProtocol,
            phone: String,
            passwword: String
        ) {
            self.authenticationService = authenticationService
            self.phone = phone
            self.password = passwword
        }

        override func main() {
            let userAttributes = [AuthenticationUserAttribute(.phoneNumber, value: phone)]
            authenticationService.signUp(
                username: phone,
                password: password,
                options: userAttributes
            ) { [weak self] result in
                defer { self?.finish() }
                guard let self = self else { return }
                self.result = result
            }
        }
    }

    final class PhoneAuthSignInOperation: AsyncOperation {
        private let authenticationService: AuthenticationServiceProtocol
        private let phone: String
        private let password: String

        var dataStore: PhoneAuthSignInDataStore?
        var authenticationHandler: ((Result<PhoneAuthModelNextStep, AuthenticationError>) -> Void)?

        init(
            authenticationService: AuthenticationServiceProtocol,
            phone: String,
            passwword: String
        ) {
            self.authenticationService = authenticationService
            self.phone = phone
            self.password = passwword
        }

        // swiftlint:disable cyclomatic_complexity
        override func main() {
            defer { finish() }
            guard let signUpResult = dataStore?.result else {
                return
            }
            switch signUpResult {
            case .failure(let error) where error.detailedError == .usernameExists:
                authenticationService.signIn(
                    username: phone,
                    password: password,
                    options: nil
                ) { [weak self] result in
                    defer { self?.finish() }
                    guard let self = self else { return }
                    switch result {
                    case .success(let state):
                        switch state.nextStep {
                        case .confirmSignInWithSMSCode(let details, _):
                            self.authenticationHandler?(
                                .success(PhoneAuthModelNextStep.confirm(details.destination))
                            )
                        case .resetPassword:
                            self.authenticationHandler?(
                                .success(PhoneAuthModelNextStep.resetPassword)
                            )
                        case .done:
                            self.authenticationHandler?(
                                .success(PhoneAuthModelNextStep.done)
                            )
                        case .confirmSignInWithNewPassword:
                            self.authenticationHandler?(
                                .success(PhoneAuthModelNextStep.setNewPassword)
                            )
                        default:
                            self.authenticationHandler?(
                                .success(PhoneAuthModelNextStep.unknown)
                            )
                        }
                    case .failure(let error):
                        self.authenticationHandler?(.failure(error))
                    }
                }
            case .success(let state):
                switch state.nextStep {
                case .confirmUser(let details, _):
                    authenticationHandler?(
                        .success(PhoneAuthModelNextStep.confirm(details?.destination ?? .unknown(nil)))
                    )
                case .done:
                    authenticationHandler?(
                        .success(PhoneAuthModelNextStep.done)
                    )
                }
            case .failure(let error):
                self.authenticationHandler?(.failure(error))
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
