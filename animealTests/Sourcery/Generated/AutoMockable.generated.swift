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














class CustomAuthModelProtocolMock: CustomAuthModelProtocol {

    // MARK: - fetchItems

    var fetchItemsCallsCount = 0
    var fetchItemsCalled: Bool {
        return fetchItemsCallsCount > 0
    }
    var fetchItemsReturnValue: [CustomAuthModelItem]!
    var fetchItemsClosure: (() -> [CustomAuthModelItem])?

    func fetchItems() -> [CustomAuthModelItem] {
        fetchItemsCallsCount += 1
        if let fetchItemsClosure = fetchItemsClosure {
            return fetchItemsClosure()
        } else {
            return fetchItemsReturnValue
        }
    }

    // MARK: - fetchItem

    var fetchItemCallsCount = 0
    var fetchItemCalled: Bool {
        return fetchItemCallsCount > 0
    }
    var fetchItemReceivedIdentifier: String?
    var fetchItemReceivedInvocations: [String] = []
    var fetchItemReturnValue: CustomAuthModelItem?
    var fetchItemClosure: ((String) -> CustomAuthModelItem?)?

    func fetchItem(_ identifier: String) -> CustomAuthModelItem? {
        fetchItemCallsCount += 1
        fetchItemReceivedIdentifier = identifier
        fetchItemReceivedInvocations.append(identifier)
        if let fetchItemClosure = fetchItemClosure {
            return fetchItemClosure(identifier)
        } else {
            return fetchItemReturnValue
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

    // MARK: - fetchRequiredAction

    var fetchRequiredActionForIdentifierCallsCount = 0
    var fetchRequiredActionForIdentifierCalled: Bool {
        return fetchRequiredActionForIdentifierCallsCount > 0
    }
    var fetchRequiredActionForIdentifierReceivedIdentifier: String?
    var fetchRequiredActionForIdentifierReceivedInvocations: [String] = []
    var fetchRequiredActionForIdentifierReturnValue: CustomAuthModelRequiredAction?
    var fetchRequiredActionForIdentifierClosure: ((String) -> CustomAuthModelRequiredAction?)?

    func fetchRequiredAction(forIdentifier identifier: String) -> CustomAuthModelRequiredAction? {
        fetchRequiredActionForIdentifierCallsCount += 1
        fetchRequiredActionForIdentifierReceivedIdentifier = identifier
        fetchRequiredActionForIdentifierReceivedInvocations.append(identifier)
        if let fetchRequiredActionForIdentifierClosure = fetchRequiredActionForIdentifierClosure {
            return fetchRequiredActionForIdentifierClosure(identifier)
        } else {
            return fetchRequiredActionForIdentifierReturnValue
        }
    }

    // MARK: - clearErrors

    var clearErrorsCallsCount = 0
    var clearErrorsCalled: Bool {
        return clearErrorsCallsCount > 0
    }
    var clearErrorsClosure: (() -> Void)?

    func clearErrors() {
        clearErrorsCallsCount += 1
        clearErrorsClosure?()
    }

    // MARK: - validate

    var validateCallsCount = 0
    var validateCalled: Bool {
        return validateCallsCount > 0
    }
    var validateReturnValue: Bool!
    var validateClosure: (() -> Bool)?

    func validate() -> Bool {
        validateCallsCount += 1
        if let validateClosure = validateClosure {
            return validateClosure()
        } else {
            return validateReturnValue
        }
    }

    // MARK: - authenticate

    var authenticateThrowableError: Error?
    var authenticateCallsCount = 0
    var authenticateCalled: Bool {
        return authenticateCallsCount > 0
    }
    var authenticateReturnValue: CustomAuthModelNextStep!
    var authenticateClosure: (() async throws -> CustomAuthModelNextStep)?

    func authenticate() async throws -> CustomAuthModelNextStep {
        if let error = authenticateThrowableError {
            throw error
        }
        authenticateCallsCount += 1
        if let authenticateClosure = authenticateClosure {
            return try await authenticateClosure()
        } else {
            return authenticateReturnValue
        }
    }

}
class CustomAuthViewItemMappableMock: CustomAuthViewItemMappable {

    // MARK: - mapItem

    var mapItemCallsCount = 0
    var mapItemCalled: Bool {
        return mapItemCallsCount > 0
    }
    var mapItemReceivedInput: CustomAuthModelItem?
    var mapItemReceivedInvocations: [CustomAuthModelItem] = []
    var mapItemReturnValue: CustomAuthViewItem!
    var mapItemClosure: ((CustomAuthModelItem) -> CustomAuthViewItem)?

    func mapItem(_ input: CustomAuthModelItem) -> CustomAuthViewItem {
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
    var mapItemsReceivedInput: [CustomAuthModelItem]?
    var mapItemsReceivedInvocations: [[CustomAuthModelItem]] = []
    var mapItemsReturnValue: [CustomAuthViewItem]!
    var mapItemsClosure: (([CustomAuthModelItem]) -> [CustomAuthViewItem])?

    func mapItems(_ input: [CustomAuthModelItem]) -> [CustomAuthViewItem] {
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
class FeedingActionMappableMock: FeedingActionMappable {

    // MARK: - mapFeedingAction

    var mapFeedingActionCallsCount = 0
    var mapFeedingActionCalled: Bool {
        return mapFeedingActionCallsCount > 0
    }
    var mapFeedingActionReceivedInput: HomeModel.FeedingAction?
    var mapFeedingActionReceivedInvocations: [HomeModel.FeedingAction] = []
    var mapFeedingActionReturnValue: FeedingActionMapper.FeedingAction!
    var mapFeedingActionClosure: ((HomeModel.FeedingAction) -> FeedingActionMapper.FeedingAction)?

    func mapFeedingAction(_ input: HomeModel.FeedingAction) -> FeedingActionMapper.FeedingAction {
        mapFeedingActionCallsCount += 1
        mapFeedingActionReceivedInput = input
        mapFeedingActionReceivedInvocations.append(input)
        if let mapFeedingActionClosure = mapFeedingActionClosure {
            return mapFeedingActionClosure(input)
        } else {
            return mapFeedingActionReturnValue
        }
    }

}
class FeedingBookingModelProtocolMock: FeedingBookingModelProtocol {

}
class FeedingPointDetailsDataStoreProtocolMock: FeedingPointDetailsDataStoreProtocol {
    var feedingPointId: String {
        get { return underlyingFeedingPointId }
        set(value) { underlyingFeedingPointId = value }
    }
    var underlyingFeedingPointId: String!

}
class FeedingPointDetailsModelProtocolMock: FeedingPointDetailsModelProtocol {

    // MARK: - fetchFeedingPoints

    var fetchFeedingPointsCallsCount = 0
    var fetchFeedingPointsCalled: Bool {
        return fetchFeedingPointsCallsCount > 0
    }
    var fetchFeedingPointsReceivedCompletion: (((FeedingPointDetailsModel.PointContent) -> Void))?
    var fetchFeedingPointsReceivedInvocations: [(((FeedingPointDetailsModel.PointContent) -> Void))?] = []
    var fetchFeedingPointsClosure: ((((FeedingPointDetailsModel.PointContent) -> Void)?) -> Void)?

    func fetchFeedingPoints(_ completion: ((FeedingPointDetailsModel.PointContent) -> Void)?) {
        fetchFeedingPointsCallsCount += 1
        fetchFeedingPointsReceivedCompletion = completion
        fetchFeedingPointsReceivedInvocations.append(completion)
        fetchFeedingPointsClosure?(completion)
    }

    // MARK: - fetchMediaContent

    var fetchMediaContentKeyCompletionCallsCount = 0
    var fetchMediaContentKeyCompletionCalled: Bool {
        return fetchMediaContentKeyCompletionCallsCount > 0
    }
    var fetchMediaContentKeyCompletionReceivedArguments: (key: String, completion: ((Data?) -> Void)?)?
    var fetchMediaContentKeyCompletionReceivedInvocations: [(key: String, completion: ((Data?) -> Void)?)] = []
    var fetchMediaContentKeyCompletionClosure: ((String, ((Data?) -> Void)?) -> Void)?

    func fetchMediaContent(key: String, completion: ((Data?) -> Void)?) {
        fetchMediaContentKeyCompletionCallsCount += 1
        fetchMediaContentKeyCompletionReceivedArguments = (key: key, completion: completion)
        fetchMediaContentKeyCompletionReceivedInvocations.append((key: key, completion: completion))
        fetchMediaContentKeyCompletionClosure?(key, completion)
    }

    // MARK: - mutateFavorite

    var mutateFavoriteCompletionCallsCount = 0
    var mutateFavoriteCompletionCalled: Bool {
        return mutateFavoriteCompletionCallsCount > 0
    }
    var mutateFavoriteCompletionReceivedCompletion: (((Bool) -> Void))?
    var mutateFavoriteCompletionReceivedInvocations: [(((Bool) -> Void))?] = []
    var mutateFavoriteCompletionClosure: ((((Bool) -> Void)?) -> Void)?

    func mutateFavorite(completion: ((Bool) -> Void)?) {
        mutateFavoriteCompletionCallsCount += 1
        mutateFavoriteCompletionReceivedCompletion = completion
        mutateFavoriteCompletionReceivedInvocations.append(completion)
        mutateFavoriteCompletionClosure?(completion)
    }

}
class FeedingPointDetailsViewMappableMock: FeedingPointDetailsViewMappable {

    // MARK: - mapFeedingPoint

    var mapFeedingPointCallsCount = 0
    var mapFeedingPointCalled: Bool {
        return mapFeedingPointCallsCount > 0
    }
    var mapFeedingPointReceivedInput: FeedingPointDetailsModel.PointContent?
    var mapFeedingPointReceivedInvocations: [FeedingPointDetailsModel.PointContent] = []
    var mapFeedingPointReturnValue: FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem!
    var mapFeedingPointClosure: ((FeedingPointDetailsModel.PointContent) -> FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem)?

    func mapFeedingPoint(_ input: FeedingPointDetailsModel.PointContent) -> FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem {
        mapFeedingPointCallsCount += 1
        mapFeedingPointReceivedInput = input
        mapFeedingPointReceivedInvocations.append(input)
        if let mapFeedingPointClosure = mapFeedingPointClosure {
            return mapFeedingPointClosure(input)
        } else {
            return mapFeedingPointReturnValue
        }
    }

    // MARK: - mapFeedingPointMediaContent

    var mapFeedingPointMediaContentCallsCount = 0
    var mapFeedingPointMediaContentCalled: Bool {
        return mapFeedingPointMediaContentCallsCount > 0
    }
    var mapFeedingPointMediaContentReceivedInput: Data?
    var mapFeedingPointMediaContentReceivedInvocations: [Data?] = []
    var mapFeedingPointMediaContentReturnValue: FeedingPointDetailsViewMapper.FeedingPointMediaContent?
    var mapFeedingPointMediaContentClosure: ((Data?) -> FeedingPointDetailsViewMapper.FeedingPointMediaContent?)?

    func mapFeedingPointMediaContent(_ input: Data?) -> FeedingPointDetailsViewMapper.FeedingPointMediaContent? {
        mapFeedingPointMediaContentCallsCount += 1
        mapFeedingPointMediaContentReceivedInput = input
        mapFeedingPointMediaContentReceivedInvocations.append(input)
        if let mapFeedingPointMediaContentClosure = mapFeedingPointMediaContentClosure {
            return mapFeedingPointMediaContentClosure(input)
        } else {
            return mapFeedingPointMediaContentReturnValue
        }
    }

}
class FeedingPointMappableMock: FeedingPointMappable {

    // MARK: - mapFeedingPoint

    var mapFeedingPointCallsCount = 0
    var mapFeedingPointCalled: Bool {
        return mapFeedingPointCallsCount > 0
    }
    var mapFeedingPointReceivedInput: animeal.FeedingPoint?
    var mapFeedingPointReceivedInvocations: [animeal.FeedingPoint] = []
    var mapFeedingPointReturnValue: HomeModel.FeedingPoint!
    var mapFeedingPointClosure: ((animeal.FeedingPoint) -> HomeModel.FeedingPoint)?

    func mapFeedingPoint(_ input: animeal.FeedingPoint) -> HomeModel.FeedingPoint {
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

    // MARK: - fetchFeedingAction

    var fetchFeedingActionRequestCallsCount = 0
    var fetchFeedingActionRequestCalled: Bool {
        return fetchFeedingActionRequestCallsCount > 0
    }
    var fetchFeedingActionRequestReceivedRequest: HomeModel.FeedingActionRequest?
    var fetchFeedingActionRequestReceivedInvocations: [HomeModel.FeedingActionRequest] = []
    var fetchFeedingActionRequestReturnValue: HomeModel.FeedingAction!
    var fetchFeedingActionRequestClosure: ((HomeModel.FeedingActionRequest) -> HomeModel.FeedingAction)?

    func fetchFeedingAction(request: HomeModel.FeedingActionRequest) -> HomeModel.FeedingAction {
        fetchFeedingActionRequestCallsCount += 1
        fetchFeedingActionRequestReceivedRequest = request
        fetchFeedingActionRequestReceivedInvocations.append(request)
        if let fetchFeedingActionRequestClosure = fetchFeedingActionRequestClosure {
            return fetchFeedingActionRequestClosure(request)
        } else {
            return fetchFeedingActionRequestReturnValue
        }
    }

    // MARK: - fetchFeedingPoint

    var fetchFeedingPointThrowableError: Error?
    var fetchFeedingPointCallsCount = 0
    var fetchFeedingPointCalled: Bool {
        return fetchFeedingPointCallsCount > 0
    }
    var fetchFeedingPointReceivedPointId: String?
    var fetchFeedingPointReceivedInvocations: [String] = []
    var fetchFeedingPointReturnValue: HomeModel.FeedingPoint!
    var fetchFeedingPointClosure: ((String) async throws -> HomeModel.FeedingPoint)?

    func fetchFeedingPoint(_ pointId: String) async throws -> HomeModel.FeedingPoint {
        if let error = fetchFeedingPointThrowableError {
            throw error
        }
        fetchFeedingPointCallsCount += 1
        fetchFeedingPointReceivedPointId = pointId
        fetchFeedingPointReceivedInvocations.append(pointId)
        if let fetchFeedingPointClosure = fetchFeedingPointClosure {
            return try await fetchFeedingPointClosure(pointId)
        } else {
            return fetchFeedingPointReturnValue
        }
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

    // MARK: - proceedFeedingPointSelection

    var proceedFeedingPointSelectionCompletionCallsCount = 0
    var proceedFeedingPointSelectionCompletionCalled: Bool {
        return proceedFeedingPointSelectionCompletionCallsCount > 0
    }
    var proceedFeedingPointSelectionCompletionReceivedArguments: (identifier: String, completion: (([HomeModel.FeedingPoint]) -> Void)?)?
    var proceedFeedingPointSelectionCompletionReceivedInvocations: [(identifier: String, completion: (([HomeModel.FeedingPoint]) -> Void)?)] = []
    var proceedFeedingPointSelectionCompletionClosure: ((String, (([HomeModel.FeedingPoint]) -> Void)?) -> Void)?

    func proceedFeedingPointSelection(_ identifier: String, completion: (([HomeModel.FeedingPoint]) -> Void)?) {
        proceedFeedingPointSelectionCompletionCallsCount += 1
        proceedFeedingPointSelectionCompletionReceivedArguments = (identifier: identifier, completion: completion)
        proceedFeedingPointSelectionCompletionReceivedInvocations.append((identifier: identifier, completion: completion))
        proceedFeedingPointSelectionCompletionClosure?(identifier, completion)
    }

    // MARK: - processCancelFeeding

    var processCancelFeedingCallsCount = 0
    var processCancelFeedingCalled: Bool {
        return processCancelFeedingCallsCount > 0
    }
    var processCancelFeedingClosure: (() -> Void)?

    func processCancelFeeding() {
        processCancelFeedingCallsCount += 1
        processCancelFeedingClosure?()
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
class LoginCoordinatableMock: LoginCoordinatable {
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

    // MARK: - proceedAuthentication

    var proceedAuthenticationThrowableError: Error?
    var proceedAuthenticationCallsCount = 0
    var proceedAuthenticationCalled: Bool {
        return proceedAuthenticationCallsCount > 0
    }
    var proceedAuthenticationReceivedType: LoginActionType?
    var proceedAuthenticationReceivedInvocations: [LoginActionType] = []
    var proceedAuthenticationReturnValue: LoginModelStatus!
    var proceedAuthenticationClosure: ((LoginActionType) async throws -> LoginModelStatus)?

    func proceedAuthentication(_ type: LoginActionType) async throws -> LoginModelStatus {
        if let error = proceedAuthenticationThrowableError {
            throw error
        }
        proceedAuthenticationCallsCount += 1
        proceedAuthenticationReceivedType = type
        proceedAuthenticationReceivedInvocations.append(type)
        if let proceedAuthenticationClosure = proceedAuthenticationClosure {
            return try await proceedAuthenticationClosure(type)
        } else {
            return proceedAuthenticationReturnValue
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
class MoreItemViewMappableMock: MoreItemViewMappable {

    // MARK: - mapActionModel

    var mapActionModelCallsCount = 0
    var mapActionModelCalled: Bool {
        return mapActionModelCallsCount > 0
    }
    var mapActionModelReceivedInput: MoreActionModel?
    var mapActionModelReceivedInvocations: [MoreActionModel] = []
    var mapActionModelReturnValue: MoreItemView!
    var mapActionModelClosure: ((MoreActionModel) -> MoreItemView)?

    func mapActionModel(_ input: MoreActionModel) -> MoreItemView {
        mapActionModelCallsCount += 1
        mapActionModelReceivedInput = input
        mapActionModelReceivedInvocations.append(input)
        if let mapActionModelClosure = mapActionModelClosure {
            return mapActionModelClosure(input)
        } else {
            return mapActionModelReturnValue
        }
    }

}
class MoreModelProtocolMock: MoreModelProtocol {

    // MARK: - fetchActions

    var fetchActionsCallsCount = 0
    var fetchActionsCalled: Bool {
        return fetchActionsCallsCount > 0
    }
    var fetchActionsReturnValue: [MoreActionModel]!
    var fetchActionsClosure: (() -> [MoreActionModel])?

    func fetchActions() -> [MoreActionModel] {
        fetchActionsCallsCount += 1
        if let fetchActionsClosure = fetchActionsClosure {
            return fetchActionsClosure()
        } else {
            return fetchActionsReturnValue
        }
    }

}
class ProfileViewItemMappableMock: ProfileViewItemMappable {

    // MARK: - mapItem

    var mapItemCallsCount = 0
    var mapItemCalled: Bool {
        return mapItemCallsCount > 0
    }
    var mapItemReceivedInput: ProfileModelItem?
    var mapItemReceivedInvocations: [ProfileModelItem] = []
    var mapItemReturnValue: ProfileViewItem!
    var mapItemClosure: ((ProfileModelItem) -> ProfileViewItem)?

    func mapItem(_ input: ProfileModelItem) -> ProfileViewItem {
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
    var mapItemsReceivedInput: [ProfileModelItem]?
    var mapItemsReceivedInvocations: [[ProfileModelItem]] = []
    var mapItemsReturnValue: [ProfileViewItem]!
    var mapItemsClosure: (([ProfileModelItem]) -> [ProfileViewItem])?

    func mapItems(_ input: [ProfileModelItem]) -> [ProfileViewItem] {
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
class SearchModelProtocolMock: SearchModelProtocol {

    // MARK: - fetchFilteringText

    var fetchFilteringTextCallsCount = 0
    var fetchFilteringTextCalled: Bool {
        return fetchFilteringTextCallsCount > 0
    }
    var fetchFilteringTextReturnValue: String?
    var fetchFilteringTextClosure: (() -> String?)?

    func fetchFilteringText() -> String? {
        fetchFilteringTextCallsCount += 1
        if let fetchFilteringTextClosure = fetchFilteringTextClosure {
            return fetchFilteringTextClosure()
        } else {
            return fetchFilteringTextReturnValue
        }
    }

    // MARK: - fetchFeedingPoints

    var fetchFeedingPointsForceThrowableError: Error?
    var fetchFeedingPointsForceCallsCount = 0
    var fetchFeedingPointsForceCalled: Bool {
        return fetchFeedingPointsForceCallsCount > 0
    }
    var fetchFeedingPointsForceReceivedForce: Bool?
    var fetchFeedingPointsForceReceivedInvocations: [Bool] = []
    var fetchFeedingPointsForceReturnValue: [SearchModelSection]!
    var fetchFeedingPointsForceClosure: ((Bool) async throws -> [SearchModelSection])?

    func fetchFeedingPoints(force: Bool) async throws -> [SearchModelSection] {
        if let error = fetchFeedingPointsForceThrowableError {
            throw error
        }
        fetchFeedingPointsForceCallsCount += 1
        fetchFeedingPointsForceReceivedForce = force
        fetchFeedingPointsForceReceivedInvocations.append(force)
        if let fetchFeedingPointsForceClosure = fetchFeedingPointsForceClosure {
            return try await fetchFeedingPointsForceClosure(force)
        } else {
            return fetchFeedingPointsForceReturnValue
        }
    }

    // MARK: - filterFeedingPoints

    var filterFeedingPointsCallsCount = 0
    var filterFeedingPointsCalled: Bool {
        return filterFeedingPointsCallsCount > 0
    }
    var filterFeedingPointsReceivedSearchString: String?
    var filterFeedingPointsReceivedInvocations: [String?] = []
    var filterFeedingPointsReturnValue: [SearchModelSection]!
    var filterFeedingPointsClosure: ((String?) async -> [SearchModelSection])?

    func filterFeedingPoints(_ searchString: String?) async -> [SearchModelSection] {
        filterFeedingPointsCallsCount += 1
        filterFeedingPointsReceivedSearchString = searchString
        filterFeedingPointsReceivedInvocations.append(searchString)
        if let filterFeedingPointsClosure = filterFeedingPointsClosure {
            return await filterFeedingPointsClosure(searchString)
        } else {
            return filterFeedingPointsReturnValue
        }
    }

    // MARK: - toogleFeedingPoint

    var toogleFeedingPointForIdentifierCallsCount = 0
    var toogleFeedingPointForIdentifierCalled: Bool {
        return toogleFeedingPointForIdentifierCallsCount > 0
    }
    var toogleFeedingPointForIdentifierReceivedIdentifier: String?
    var toogleFeedingPointForIdentifierReceivedInvocations: [String] = []
    var toogleFeedingPointForIdentifierClosure: ((String) -> Void)?

    func toogleFeedingPoint(forIdentifier identifier: String) {
        toogleFeedingPointForIdentifierCallsCount += 1
        toogleFeedingPointForIdentifierReceivedIdentifier = identifier
        toogleFeedingPointForIdentifierReceivedInvocations.append(identifier)
        toogleFeedingPointForIdentifierClosure?(identifier)
    }

}
class SearchViewItemMappableMock: SearchViewItemMappable {

    // MARK: - mapItem

    var mapItemCallsCount = 0
    var mapItemCalled: Bool {
        return mapItemCallsCount > 0
    }
    var mapItemReceivedInput: SearchModelItem?
    var mapItemReceivedInvocations: [SearchModelItem] = []
    var mapItemReturnValue: SearchViewItem!
    var mapItemClosure: ((SearchModelItem) -> SearchViewItem)?

    func mapItem(_ input: SearchModelItem) -> SearchViewItem {
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
    var mapItemsReceivedInput: [SearchModelItem]?
    var mapItemsReceivedInvocations: [[SearchModelItem]] = []
    var mapItemsReturnValue: [SearchViewItem]!
    var mapItemsClosure: (([SearchModelItem]) -> [SearchViewItem])?

    func mapItems(_ input: [SearchModelItem]) -> [SearchViewItem] {
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
class SearchViewSectionMappableMock: SearchViewSectionMappable {

    // MARK: - mapSection

    var mapSectionCallsCount = 0
    var mapSectionCalled: Bool {
        return mapSectionCallsCount > 0
    }
    var mapSectionReceivedInput: SearchModelSection?
    var mapSectionReceivedInvocations: [SearchModelSection] = []
    var mapSectionReturnValue: SearchViewSectionWrapper!
    var mapSectionClosure: ((SearchModelSection) -> SearchViewSectionWrapper)?

    func mapSection(_ input: SearchModelSection) -> SearchViewSectionWrapper {
        mapSectionCallsCount += 1
        mapSectionReceivedInput = input
        mapSectionReceivedInvocations.append(input)
        if let mapSectionClosure = mapSectionClosure {
            return mapSectionClosure(input)
        } else {
            return mapSectionReturnValue
        }
    }

    // MARK: - mapSections

    var mapSectionsCallsCount = 0
    var mapSectionsCalled: Bool {
        return mapSectionsCallsCount > 0
    }
    var mapSectionsReceivedInput: [SearchModelSection]?
    var mapSectionsReceivedInvocations: [[SearchModelSection]] = []
    var mapSectionsReturnValue: [SearchViewSectionWrapper]!
    var mapSectionsClosure: (([SearchModelSection]) -> [SearchViewSectionWrapper])?

    func mapSections(_ input: [SearchModelSection]) -> [SearchViewSectionWrapper] {
        mapSectionsCallsCount += 1
        mapSectionsReceivedInput = input
        mapSectionsReceivedInvocations.append(input)
        if let mapSectionsClosure = mapSectionsClosure {
            return mapSectionsClosure(input)
        } else {
            return mapSectionsReturnValue
        }
    }

}
class VerificationModelProtocolMock: VerificationModelProtocol {
    var requestNewCodeTimeLeft: ((VerificationModelTimeLeft) -> Void)?

    // MARK: - fetchDestination

    var fetchDestinationCallsCount = 0
    var fetchDestinationCalled: Bool {
        return fetchDestinationCallsCount > 0
    }
    var fetchDestinationReturnValue: VerificationModelDeliveryDestination!
    var fetchDestinationClosure: (() -> VerificationModelDeliveryDestination)?

    func fetchDestination() -> VerificationModelDeliveryDestination {
        fetchDestinationCallsCount += 1
        if let fetchDestinationClosure = fetchDestinationClosure {
            return fetchDestinationClosure()
        } else {
            return fetchDestinationReturnValue
        }
    }

    // MARK: - fetchCode

    var fetchCodeCallsCount = 0
    var fetchCodeCalled: Bool {
        return fetchCodeCallsCount > 0
    }
    var fetchCodeReturnValue: VerificationModelCode!
    var fetchCodeClosure: (() -> VerificationModelCode)?

    func fetchCode() -> VerificationModelCode {
        fetchCodeCallsCount += 1
        if let fetchCodeClosure = fetchCodeClosure {
            return fetchCodeClosure()
        } else {
            return fetchCodeReturnValue
        }
    }

    // MARK: - requestNewCode

    var requestNewCodeForceThrowableError: Error?
    var requestNewCodeForceCallsCount = 0
    var requestNewCodeForceCalled: Bool {
        return requestNewCodeForceCallsCount > 0
    }
    var requestNewCodeForceReceivedForce: Bool?
    var requestNewCodeForceReceivedInvocations: [Bool] = []
    var requestNewCodeForceClosure: ((Bool) async throws -> Void)?

    func requestNewCode(force: Bool) async throws {
        if let error = requestNewCodeForceThrowableError {
            throw error
        }
        requestNewCodeForceCallsCount += 1
        requestNewCodeForceReceivedForce = force
        requestNewCodeForceReceivedInvocations.append(force)
        try await requestNewCodeForceClosure?(force)
    }

    // MARK: - validateCode

    var validateCodeThrowableError: Error?
    var validateCodeCallsCount = 0
    var validateCodeCalled: Bool {
        return validateCodeCallsCount > 0
    }
    var validateCodeReceivedCode: VerificationModelCode?
    var validateCodeReceivedInvocations: [VerificationModelCode] = []
    var validateCodeClosure: ((VerificationModelCode) throws -> Void)?

    func validateCode(_ code: VerificationModelCode) throws {
        if let error = validateCodeThrowableError {
            throw error
        }
        validateCodeCallsCount += 1
        validateCodeReceivedCode = code
        validateCodeReceivedInvocations.append(code)
        try validateCodeClosure?(code)
    }

    // MARK: - verifyCode

    var verifyCodeThrowableError: Error?
    var verifyCodeCallsCount = 0
    var verifyCodeCalled: Bool {
        return verifyCodeCallsCount > 0
    }
    var verifyCodeReceivedCode: VerificationModelCode?
    var verifyCodeReceivedInvocations: [VerificationModelCode] = []
    var verifyCodeClosure: ((VerificationModelCode) async throws -> Void)?

    func verifyCode(_ code: VerificationModelCode) async throws {
        if let error = verifyCodeThrowableError {
            throw error
        }
        verifyCodeCallsCount += 1
        verifyCodeReceivedCode = code
        verifyCodeReceivedInvocations.append(code)
        try await verifyCodeClosure?(code)
    }

}
