// System
import Foundation

// SDK
import Services
import Common

final class CustomAuthModel: CustomAuthModelProtocol {
    // MARK: - Private properties
    private let options: CustomAuthModelOptions
    private var items: [CustomAuthModelComponent: CustomAuthModelItem]

    // MARK: - Dependencies
    private let authenticationService: AuthenticationServiceProtocol

    // MARK: - Initializations
    init(
        items: [CustomAuthModelComponent: CustomAuthModelItem] = .paswordlessItems,
        options: CustomAuthModelOptions = .passwordless,
        authenticationService: AuthenticationServiceProtocol = AppDelegate.shared.context.authenticationService
    ) {
        self.items = items
        self.options = options
        self.authenticationService = authenticationService
    }

    // MARK: - Requests
    func fetchItems() -> [CustomAuthModelItem] { items.values.map { $0 } }

    func fetchItem(_ identifier: String) -> CustomAuthModelItem? {
        guard
            let item = items.values.first(where: { $0.identifier == identifier })
        else { return nil }
        return item
    }

    func updateItem(_ text: String?, forIdentifier identifier: String) {
        guard
            let item = items.first(where: { $0.value.identifier == identifier })
        else { return }
        if var value = items[item.key] {
            value.text = text
            items[item.key] = value
        }
    }

    func clearErrors() {
        items.values.forEach {
            updateItem(.normal, forIdentifier: $0.identifier)
        }
    }

    func validate() -> Bool {
        do {
            guard let usernameItem = items[.username] else { throw "".asBaseError() }
            _ = try AuthenticationInput(usernameItem.validate)
            let _: AuthenticationInput? = try {
                guard !options.contains(.passwordless), let passwordItem = items[.password] else {
                    return nil
                }
                return try AuthenticationInput(passwordItem.validate)
            }()
            return true
        } catch let error as CustomAuthModelItemError {
            updateItem(.error(error.localizedDescription), forIdentifier: error.itemIdentifier)
            return false
        } catch {
            return false
        }
    }

    func authenticate() async throws -> CustomAuthModelNextStep {
        do {
            guard let usernameItem = items[.username] else { throw "Username cannot be nil".asBaseError() }
            let username = try AuthenticationInput(usernameItem.validate)
            let password: AuthenticationInput? = try {
                guard !options.contains(.passwordless), let passwordItem = items[.password] else {
                    return nil
                }
                return try AuthenticationInput(passwordItem.validate)
            }()
            return try await authenticate(
                username: username,
                password: password,
                attributes: items.values.compactMap { $0.authenticationUserAttribute }
            )
        } catch let error as CustomAuthModelItemError {
            updateItem(error.localizedDescription, forIdentifier: error.itemIdentifier)
            throw error
        } catch {
            throw error
        }
    }
}

private extension CustomAuthModel {
    func updateItem(_ state: CustomAuthItemState, forIdentifier identifier: String) {
        guard
            let item = items.first(where: { $0.value.identifier == identifier })
        else { return }
        if var value = items[item.key] {
            value.state = state
            items[item.key] = value
        }
    }

    func authenticate(
        username: AuthenticationInput,
        password: AuthenticationInput?,
        attributes: [AuthenticationUserAttribute]
    ) async throws -> CustomAuthModelNextStep {
        do {
            let signUpResult = try await authenticationService.signUp(
                username: username,
                password: password ?? AuthenticationInput { UUID().uuidString },
                options: attributes
            )
            switch signUpResult.nextStep {
            case .done:
                let signInResult = try await authenticationService.signIn(
                    username: username,
                    password: password
                )
                return try CustomAuthModelNextStep.afterSignIn(signInResult)
            case .confirmUser:
                throw "Unsupported next step".asBaseError()
            }
        } catch AuthenticationError.service(_, _, let error)
                    where (error as? AuthenticationDetailedError) == .usernameExists {
            let signInResult = try await authenticationService.signIn(
                username: username,
                password: password
            )
            return try CustomAuthModelNextStep.afterSignIn(signInResult)
        } catch {
            throw error
        }
    }
}

private extension CustomAuthModelNextStep {
    static func afterSignIn(_ result: AuthenticationSignInState) throws -> Self {
        switch result.nextStep {
        case .confirmSignInWithCustomChallenge:
            return CustomAuthModelNextStep.confirm(.init(destination: .sms(nil)))
        case .confirmSignInWithSMSCode(let details, _):
            return CustomAuthModelNextStep.confirm(details)
        case .done:
            return CustomAuthModelNextStep.done
        default:
            throw "Unsupported next step".asBaseError()
        }
    }
}

private extension CustomAuthModelItem {
    var authenticationUserAttribute: AuthenticationUserAttribute? {
        switch type {
        case .phone(let region):
            return AuthenticationUserAttribute(
                .phoneNumber,
                value: region.phoneNumberCode + (text ?? .empty)
            )
        case .password:
            return nil
        }
    }
}

private extension Dictionary where Key == CustomAuthModelComponent, Value == CustomAuthModelItem {
    static var paswordlessItems: Self {
        [
            CustomAuthModelComponent.username: CustomAuthModelItem(
                identifier: UUID().uuidString,
                type: CustomAuthItemType.phone(.GE),
                style: CustomAuthItemStyle.editable,
                state: CustomAuthItemState.normal
            )
        ]
    }
}
