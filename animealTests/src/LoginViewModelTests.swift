import XCTest
@testable import animeal

@MainActor
class LoginViewModelTests: XCTestCase {
    private var sut: LoginViewModel!

    override func setUpWithError() throws {
        let coordinator = LoginCoordinatorMock()
        let model = LoginModel(
            providers: [
                LoginActionType.signInViaPhoneNumber: nil
            ]
        )
        let viewModel = LoginViewModel(
            model: model,
            coordinator: coordinator,
            actionsMapper: LoginViewActionMapper(),
            onboardingMapper: LoginViewOnboardingStepsMapper()
        )
        sut = viewModel
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testPreparedForOnboarding() throws {
        // GIVEN
        // Prepare the view model with required data
        let onboardingStepsHaveBeenPrepared = XCTestExpectation(description: "OnboardingStepsHaveBeenPrepared")
        let actionsHaveBeenPrepaped = XCTestExpectation(description: "ActionsHaveBeenPrepaped")
        var loginViewAction: LoginViewAction?
        var loginViewOnboardingStep: LoginViewOnboardingStep?
        sut.onOnboardingStepsHaveBeenPrepared = { steps in
            loginViewOnboardingStep = steps.first
            onboardingStepsHaveBeenPrepared.fulfill()
        }

        sut.onActionsHaveBeenPrepaped = { actions in
            loginViewAction = actions.first
            actionsHaveBeenPrepaped.fulfill()
        }
        // WHEN
        sut.load()

        // THEN
        wait(for: [onboardingStepsHaveBeenPrepared, actionsHaveBeenPrepaped], timeout: 2)
        let actionIdentifier = try XCTUnwrap(loginViewAction?.identifier)
        let loginViewOnboardingStepIdentifier = try XCTUnwrap(loginViewOnboardingStep?.title)
        XCTAssertEqual(actionIdentifier, "signInViaPhoneNumber")
        XCTAssertEqual(loginViewOnboardingStepIdentifier, "Take care of pets")
    }
}

// MARK: - Mock Co-ordinator
class LoginCoordinatorMock: LoginCoordinatable {
    var navigator: Navigating {
        get { return underlyingNavigator }
        set(value) { underlyingNavigator = value }
    }
    var underlyingNavigator: Navigating!

    // MARK: - moveFromLogin
    var moveFromLoginToCallsCount = 0
    var moveFromLoginToCalled: Bool {
        return moveFromLoginToCallsCount > 0
    }
    var moveFromLoginToReceivedRoute: LoginRoute?
    var moveFromLoginToReceivedInvocations: [LoginRoute] = []
    var moveFromLoginToClosure: ((LoginRoute) -> Void)?

    func moveFromLogin(to route: LoginRoute) {
        moveFromLoginToCallsCount += 1
        moveFromLoginToReceivedRoute = route
        moveFromLoginToReceivedInvocations.append(route)
        moveFromLoginToClosure?(route)
    }

    // MARK: - start
    var startCallsCount = 0
    var startCalled: Bool {
        return startCallsCount > 0
    }
    var startClosure: (() -> Void)?

    @MainActor
    func start() {
        startCallsCount += 1
        startClosure?()
    }

    // MARK: - stop

    var stopCallsCount = 0
    var stopCalled: Bool {
        return stopCallsCount > 0
    }
    var stopClosure: (() -> Void)?

    @MainActor
    func stop() {
        stopCallsCount += 1
        stopClosure?()
    }
}
