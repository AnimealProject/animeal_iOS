// Generated using Sourcery 1.8.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable vertical_whitespace
// swiftlint:disable vertical_whitespace_closing_braces

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import CoreLocation


@testable import animeal
@testable import Services














class LocationServiceDelegateMock: LocationServiceDelegate {

    // MARK: - handleLiveLocationStream

    var handleLiveLocationStreamResultCallsCount = 0
    var handleLiveLocationStreamResultCalled: Bool {
        return handleLiveLocationStreamResultCallsCount > 0
    }
    var handleLiveLocationStreamResultReceivedResult: Result<CLLocation, Error>?
    var handleLiveLocationStreamResultReceivedInvocations: [Result<CLLocation, Error>] = []
    var handleLiveLocationStreamResultClosure: ((Result<CLLocation, Error>) -> Void)?

    func handleLiveLocationStream(result: Result<CLLocation, Error>) {
        handleLiveLocationStreamResultCallsCount += 1
        handleLiveLocationStreamResultReceivedResult = result
        handleLiveLocationStreamResultReceivedInvocations.append(result)
        handleLiveLocationStreamResultClosure?(result)
    }

    // MARK: - handleOneTimeLocation

    var handleOneTimeLocationResultCallsCount = 0
    var handleOneTimeLocationResultCalled: Bool {
        return handleOneTimeLocationResultCallsCount > 0
    }
    var handleOneTimeLocationResultReceivedResult: Result<CLLocation, Error>?
    var handleOneTimeLocationResultReceivedInvocations: [Result<CLLocation, Error>] = []
    var handleOneTimeLocationResultClosure: ((Result<CLLocation, Error>) -> Void)?

    func handleOneTimeLocation(result: Result<CLLocation, Error>) {
        handleOneTimeLocationResultCallsCount += 1
        handleOneTimeLocationResultReceivedResult = result
        handleOneTimeLocationResultReceivedInvocations.append(result)
        handleOneTimeLocationResultClosure?(result)
    }

}
class LocationServiceProtocolMock: LocationServiceProtocol {

    // MARK: - requestLocation

    var requestLocationForCallsCount = 0
    var requestLocationForCalled: Bool {
        return requestLocationForCallsCount > 0
    }
    var requestLocationForReceivedDelegate: LocationServiceDelegate?
    var requestLocationForReceivedInvocations: [LocationServiceDelegate] = []
    var requestLocationForClosure: ((LocationServiceDelegate) -> Void)?

    func requestLocation(for delegate: LocationServiceDelegate) {
        requestLocationForCallsCount += 1
        requestLocationForReceivedDelegate = delegate
        requestLocationForReceivedInvocations.append(delegate)
        requestLocationForClosure?(delegate)
    }

    // MARK: - startUpdatingLocation

    var startUpdatingLocationForCallsCount = 0
    var startUpdatingLocationForCalled: Bool {
        return startUpdatingLocationForCallsCount > 0
    }
    var startUpdatingLocationForReceivedDelegate: LocationServiceDelegate?
    var startUpdatingLocationForReceivedInvocations: [LocationServiceDelegate] = []
    var startUpdatingLocationForClosure: ((LocationServiceDelegate) -> Void)?

    func startUpdatingLocation(for delegate: LocationServiceDelegate) {
        startUpdatingLocationForCallsCount += 1
        startUpdatingLocationForReceivedDelegate = delegate
        startUpdatingLocationForReceivedInvocations.append(delegate)
        startUpdatingLocationForClosure?(delegate)
    }

    // MARK: - stopUpdatingLocation

    var stopUpdatingLocationForCallsCount = 0
    var stopUpdatingLocationForCalled: Bool {
        return stopUpdatingLocationForCallsCount > 0
    }
    var stopUpdatingLocationForReceivedDelegate: LocationServiceDelegate?
    var stopUpdatingLocationForReceivedInvocations: [LocationServiceDelegate] = []
    var stopUpdatingLocationForClosure: ((LocationServiceDelegate) -> Void)?

    func stopUpdatingLocation(for delegate: LocationServiceDelegate) {
        stopUpdatingLocationForCallsCount += 1
        stopUpdatingLocationForReceivedDelegate = delegate
        stopUpdatingLocationForReceivedInvocations.append(delegate)
        stopUpdatingLocationForClosure?(delegate)
    }

}
class LoginModelProtocolMock: LoginModelProtocol {

    // MARK: - fetchOnboardingSteps

    var fetchOnboardingStepsCallsCount = 0
    var fetchOnboardingStepsCalled: Bool {
        return fetchOnboardingStepsCallsCount > 0
    }
    var fetchOnboardingStepsReturnValue: [LoginModelOnboardingStep]!
    var fetchOnboardingStepsClosure: (() -> [LoginModelOnboardingStep])?

    func fetchOnboardingSteps() -> [LoginModelOnboardingStep] {
        fetchOnboardingStepsCallsCount += 1
        if let fetchOnboardingStepsClosure = fetchOnboardingStepsClosure {
            return fetchOnboardingStepsClosure()
        } else {
            return fetchOnboardingStepsReturnValue
        }
    }

    // MARK: - fetchActions

    var fetchActionsCallsCount = 0
    var fetchActionsCalled: Bool {
        return fetchActionsCallsCount > 0
    }
    var fetchActionsReturnValue: [LoginModelAction]!
    var fetchActionsClosure: (() -> [LoginModelAction])?

    func fetchActions() -> [LoginModelAction] {
        fetchActionsCallsCount += 1
        if let fetchActionsClosure = fetchActionsClosure {
            return fetchActionsClosure()
        } else {
            return fetchActionsReturnValue
        }
    }

}
class LoginViewActionMappableMock: LoginViewActionMappable {

    // MARK: - mapAction

    var mapActionCallsCount = 0
    var mapActionCalled: Bool {
        return mapActionCallsCount > 0
    }
    var mapActionReceivedInput: LoginModelAction?
    var mapActionReceivedInvocations: [LoginModelAction] = []
    var mapActionReturnValue: LoginViewAction!
    var mapActionClosure: ((LoginModelAction) -> LoginViewAction)?

    func mapAction(_ input: LoginModelAction) -> LoginViewAction {
        mapActionCallsCount += 1
        mapActionReceivedInput = input
        mapActionReceivedInvocations.append(input)
        if let mapActionClosure = mapActionClosure {
            return mapActionClosure(input)
        } else {
            return mapActionReturnValue
        }
    }

    // MARK: - mapActions

    var mapActionsCallsCount = 0
    var mapActionsCalled: Bool {
        return mapActionsCallsCount > 0
    }
    var mapActionsReceivedInput: [LoginModelAction]?
    var mapActionsReceivedInvocations: [[LoginModelAction]] = []
    var mapActionsReturnValue: [LoginViewAction]!
    var mapActionsClosure: (([LoginModelAction]) -> [LoginViewAction])?

    func mapActions(_ input: [LoginModelAction]) -> [LoginViewAction] {
        mapActionsCallsCount += 1
        mapActionsReceivedInput = input
        mapActionsReceivedInvocations.append(input)
        if let mapActionsClosure = mapActionsClosure {
            return mapActionsClosure(input)
        } else {
            return mapActionsReturnValue
        }
    }

}
class LoginViewOnboardingStepsMappableMock: LoginViewOnboardingStepsMappable {

    // MARK: - mapStep

    var mapStepCallsCount = 0
    var mapStepCalled: Bool {
        return mapStepCallsCount > 0
    }
    var mapStepReceivedInput: LoginModelOnboardingStep?
    var mapStepReceivedInvocations: [LoginModelOnboardingStep] = []
    var mapStepReturnValue: LoginViewOnboardingStep!
    var mapStepClosure: ((LoginModelOnboardingStep) -> LoginViewOnboardingStep)?

    func mapStep(_ input: LoginModelOnboardingStep) -> LoginViewOnboardingStep {
        mapStepCallsCount += 1
        mapStepReceivedInput = input
        mapStepReceivedInvocations.append(input)
        if let mapStepClosure = mapStepClosure {
            return mapStepClosure(input)
        } else {
            return mapStepReturnValue
        }
    }

    // MARK: - mapSteps

    var mapStepsCallsCount = 0
    var mapStepsCalled: Bool {
        return mapStepsCallsCount > 0
    }
    var mapStepsReceivedInput: [LoginModelOnboardingStep]?
    var mapStepsReceivedInvocations: [[LoginModelOnboardingStep]] = []
    var mapStepsReturnValue: [LoginViewOnboardingStep]!
    var mapStepsClosure: (([LoginModelOnboardingStep]) -> [LoginViewOnboardingStep])?

    func mapSteps(_ input: [LoginModelOnboardingStep]) -> [LoginViewOnboardingStep] {
        mapStepsCallsCount += 1
        mapStepsReceivedInput = input
        mapStepsReceivedInvocations.append(input)
        if let mapStepsClosure = mapStepsClosure {
            return mapStepsClosure(input)
        } else {
            return mapStepsReturnValue
        }
    }

}
