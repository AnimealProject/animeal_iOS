// Generated using Sourcery 1.8.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import CoreLocation


@testable import animeal
@testable import Services














class FeedingPointViewMappableMock: FeedingPointViewMappable {

    // MARK: - mapFeedingPoint

    var mapFeedingPointCallsCount = 0
    var mapFeedingPointCalled: Bool {
        return mapFeedingPointCallsCount > 0
    }
    var mapFeedingPointReceivedInput: HomeModel.FeedingPoint?
    var mapFeedingPointReceivedInvocations: [HomeModel.FeedingPoint] = []
    var mapFeedingPointReturnValue: FeedingPointViewItem!
    var mapFeedingPointClosure: ((HomeModel.FeedingPoint) -> FeedingPointViewItem)?

    func mapFeedingPoint(_ input: HomeModel.FeedingPoint) -> FeedingPointViewItem {
        mapFeedingPointCallsCount += 1
        mapFeedingPointReceivedInput = input
        mapFeedingPointReceivedInvocations.append(input)
        if let mapFeedingPointClosure = mapFeedingPointClosure {
            return mapFeedingPointClosure(input)
        } else {
            return mapFeedingPointReturnValue
        }
    }

}
class FilterViewMappableMock: FilterViewMappable {

    // MARK: - mapFilterModel

    var mapFilterModelCallsCount = 0
    var mapFilterModelCalled: Bool {
        return mapFilterModelCallsCount > 0
    }
    var mapFilterModelReceivedInput: [HomeModel.FilterItem]?
    var mapFilterModelReceivedInvocations: [[HomeModel.FilterItem]] = []
    var mapFilterModelReturnValue: FilterModel!
    var mapFilterModelClosure: (([HomeModel.FilterItem]) -> FilterModel)?

    func mapFilterModel(_ input: [HomeModel.FilterItem]) -> FilterModel {
        mapFilterModelCallsCount += 1
        mapFilterModelReceivedInput = input
        mapFilterModelReceivedInvocations.append(input)
        if let mapFilterModelClosure = mapFilterModelClosure {
            return mapFilterModelClosure(input)
        } else {
            return mapFilterModelReturnValue
        }
    }

}
class HomeModelProtocolMock: HomeModelProtocol {

    // MARK: - fetchFeedingPoints

    var fetchFeedingPointsCallsCount = 0
    var fetchFeedingPointsCalled: Bool {
        return fetchFeedingPointsCallsCount > 0
    }
    var fetchFeedingPointsReceivedCompletion: ((([HomeModel.FeedingPoint]) -> Void))?
    var fetchFeedingPointsReceivedInvocations: [((([HomeModel.FeedingPoint]) -> Void))?] = []
    var fetchFeedingPointsClosure: (((([HomeModel.FeedingPoint]) -> Void)?) -> Void)?

    func fetchFeedingPoints(_ completion: (([HomeModel.FeedingPoint]) -> Void)?) {
        fetchFeedingPointsCallsCount += 1
        fetchFeedingPointsReceivedCompletion = completion
        fetchFeedingPointsReceivedInvocations.append(completion)
        fetchFeedingPointsClosure?(completion)
    }

    // MARK: - fetchFilterItems

    var fetchFilterItemsCallsCount = 0
    var fetchFilterItemsCalled: Bool {
        return fetchFilterItemsCallsCount > 0
    }
    var fetchFilterItemsReceivedCompletion: ((([HomeModel.FilterItem]) -> Void))?
    var fetchFilterItemsReceivedInvocations: [((([HomeModel.FilterItem]) -> Void))?] = []
    var fetchFilterItemsClosure: (((([HomeModel.FilterItem]) -> Void)?) -> Void)?

    func fetchFilterItems(_ completion: (([HomeModel.FilterItem]) -> Void)?) {
        fetchFilterItemsCallsCount += 1
        fetchFilterItemsReceivedCompletion = completion
        fetchFilterItemsReceivedInvocations.append(completion)
        fetchFilterItemsClosure?(completion)
    }

    // MARK: - proceedFilter

    var proceedFilterCallsCount = 0
    var proceedFilterCalled: Bool {
        return proceedFilterCallsCount > 0
    }
    var proceedFilterReceivedIdentifier: HomeModel.FilterItemIdentifier?
    var proceedFilterReceivedInvocations: [HomeModel.FilterItemIdentifier] = []
    var proceedFilterClosure: ((HomeModel.FilterItemIdentifier) -> Void)?

    func proceedFilter(_ identifier: HomeModel.FilterItemIdentifier) {
        proceedFilterCallsCount += 1
        proceedFilterReceivedIdentifier = identifier
        proceedFilterReceivedInvocations.append(identifier)
        proceedFilterClosure?(identifier)
    }

}
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
    var proceedAuthentificationResponse: ((LoginModelStatus) -> Void)?

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

    // MARK: - proceedAuthentication

    var proceedAuthenticationCallsCount = 0
    var proceedAuthenticationCalled: Bool {
        return proceedAuthenticationCallsCount > 0
    }
    var proceedAuthenticationReceivedType: LoginActionType?
    var proceedAuthenticationReceivedInvocations: [LoginActionType] = []
    var proceedAuthenticationClosure: ((LoginActionType) -> Void)?

    func proceedAuthentication(_ type: LoginActionType) {
        proceedAuthenticationCallsCount += 1
        proceedAuthenticationReceivedType = type
        proceedAuthenticationReceivedInvocations.append(type)
        proceedAuthenticationClosure?(type)
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
class PhoneAuthModelProtocolMock: PhoneAuthModelProtocol {
    var fetchItemsResponse: (([PhoneAuthModelItem]) -> Void)?
    var proceedAuthenticationResponse: ((Result<PhoneAuthModelNextStep, Error>) -> Void)?

    // MARK: - fetchItems

    var fetchItemsCallsCount = 0
    var fetchItemsCalled: Bool {
        return fetchItemsCallsCount > 0
    }
    var fetchItemsClosure: (() -> Void)?

    func fetchItems() {
        fetchItemsCallsCount += 1
        fetchItemsClosure?()
    }

    // MARK: - fetchItem

    var fetchItemCallsCount = 0
    var fetchItemCalled: Bool {
        return fetchItemCallsCount > 0
    }
    var fetchItemReceivedIdentifier: String?
    var fetchItemReceivedInvocations: [String] = []
    var fetchItemReturnValue: PhoneAuthModelItem?
    var fetchItemClosure: ((String) -> PhoneAuthModelItem?)?

    func fetchItem(_ identifier: String) -> PhoneAuthModelItem? {
        fetchItemCallsCount += 1
        fetchItemReceivedIdentifier = identifier
        fetchItemReceivedInvocations.append(identifier)
        if let fetchItemClosure = fetchItemClosure {
            return fetchItemClosure(identifier)
        } else {
            return fetchItemReturnValue
        }
    }

    // MARK: - validateItems

    var validateItemsCallsCount = 0
    var validateItemsCalled: Bool {
        return validateItemsCallsCount > 0
    }
    var validateItemsReturnValue: Bool!
    var validateItemsClosure: (() -> Bool)?

    func validateItems() -> Bool {
        validateItemsCallsCount += 1
        if let validateItemsClosure = validateItemsClosure {
            return validateItemsClosure()
        } else {
            return validateItemsReturnValue
        }
    }

    // MARK: - updateItem

    var updateItemForIdentifierCallsCount = 0
    var updateItemForIdentifierCalled: Bool {
        return updateItemForIdentifierCallsCount > 0
    }
    var updateItemForIdentifierReceivedArguments: (text: String?, identifier: String)?
    var updateItemForIdentifierReceivedInvocations: [(text: String?, identifier: String)] = []
    var updateItemForIdentifierClosure: ((String?, String) -> Void)?

    func updateItem(_ text: String?, forIdentifier identifier: String) {
        updateItemForIdentifierCallsCount += 1
        updateItemForIdentifierReceivedArguments = (text: text, identifier: identifier)
        updateItemForIdentifierReceivedInvocations.append((text: text, identifier: identifier))
        updateItemForIdentifierClosure?(text, identifier)
    }

    // MARK: - proceedAuthentication

    var proceedAuthenticationCallsCount = 0
    var proceedAuthenticationCalled: Bool {
        return proceedAuthenticationCallsCount > 0
    }
    var proceedAuthenticationClosure: (() -> Void)?

    func proceedAuthentication() {
        proceedAuthenticationCallsCount += 1
        proceedAuthenticationClosure?()
    }

}
class PhoneAuthViewItemMappableMock: PhoneAuthViewItemMappable {

    // MARK: - mapItem

    var mapItemCallsCount = 0
    var mapItemCalled: Bool {
        return mapItemCallsCount > 0
    }
    var mapItemReceivedInput: PhoneAuthModelItem?
    var mapItemReceivedInvocations: [PhoneAuthModelItem] = []
    var mapItemReturnValue: PhoneAuthViewItem!
    var mapItemClosure: ((PhoneAuthModelItem) -> PhoneAuthViewItem)?

    func mapItem(_ input: PhoneAuthModelItem) -> PhoneAuthViewItem {
        mapItemCallsCount += 1
        mapItemReceivedInput = input
        mapItemReceivedInvocations.append(input)
        if let mapItemClosure = mapItemClosure {
            return mapItemClosure(input)
        } else {
            return mapItemReturnValue
        }
    }

    // MARK: - mapItems

    var mapItemsCallsCount = 0
    var mapItemsCalled: Bool {
        return mapItemsCallsCount > 0
    }
    var mapItemsReceivedInput: [PhoneAuthModelItem]?
    var mapItemsReceivedInvocations: [[PhoneAuthModelItem]] = []
    var mapItemsReturnValue: [PhoneAuthViewItem]!
    var mapItemsClosure: (([PhoneAuthModelItem]) -> [PhoneAuthViewItem])?

    func mapItems(_ input: [PhoneAuthModelItem]) -> [PhoneAuthViewItem] {
        mapItemsCallsCount += 1
        mapItemsReceivedInput = input
        mapItemsReceivedInvocations.append(input)
        if let mapItemsClosure = mapItemsClosure {
            return mapItemsClosure(input)
        } else {
            return mapItemsReturnValue
        }
    }

}
class VerificationModelProtocolMock: VerificationModelProtocol {
    var fetchNewCodeResponse: ((VerificationModelCode) -> Void)?
    var fetchNewCodeResponseTimeLeft: ((VerificationModelTimeLeft) -> Void)?

    // MARK: - isValidationNeeded

    var isValidationNeededCallsCount = 0
    var isValidationNeededCalled: Bool {
        return isValidationNeededCallsCount > 0
    }
    var isValidationNeededReceivedCode: VerificationModelCode?
    var isValidationNeededReceivedInvocations: [VerificationModelCode] = []
    var isValidationNeededReturnValue: Bool!
    var isValidationNeededClosure: ((VerificationModelCode) -> Bool)?

    func isValidationNeeded(_ code: VerificationModelCode) -> Bool {
        isValidationNeededCallsCount += 1
        isValidationNeededReceivedCode = code
        isValidationNeededReceivedInvocations.append(code)
        if let isValidationNeededClosure = isValidationNeededClosure {
            return isValidationNeededClosure(code)
        } else {
            return isValidationNeededReturnValue
        }
    }

    // MARK: - validateCode

    var validateCodeCallsCount = 0
    var validateCodeCalled: Bool {
        return validateCodeCallsCount > 0
    }
    var validateCodeReceivedCode: VerificationModelCode?
    var validateCodeReceivedInvocations: [VerificationModelCode] = []
    var validateCodeReturnValue: Bool!
    var validateCodeClosure: ((VerificationModelCode) -> Bool)?

    func validateCode(_ code: VerificationModelCode) -> Bool {
        validateCodeCallsCount += 1
        validateCodeReceivedCode = code
        validateCodeReceivedInvocations.append(code)
        if let validateCodeClosure = validateCodeClosure {
            return validateCodeClosure(code)
        } else {
            return validateCodeReturnValue
        }
    }

    // MARK: - fetchInitialCode

    var fetchInitialCodeCallsCount = 0
    var fetchInitialCodeCalled: Bool {
        return fetchInitialCodeCallsCount > 0
    }
    var fetchInitialCodeClosure: (() -> Void)?

    func fetchInitialCode() {
        fetchInitialCodeCallsCount += 1
        fetchInitialCodeClosure?()
    }

    // MARK: - fetchNewCode

    var fetchNewCodeCallsCount = 0
    var fetchNewCodeCalled: Bool {
        return fetchNewCodeCallsCount > 0
    }
    var fetchNewCodeClosure: (() -> Void)?

    func fetchNewCode() {
        fetchNewCodeCallsCount += 1
        fetchNewCodeClosure?()
    }

}
