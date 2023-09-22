import UIKit

// MARK: - View
protocol DonateViewable: AnyObject {
}

// MARK: - ViewModel
typealias DonateViewModelProtocol = DonateViewModelLifeCycle
    & DonateViewInteraction
    & DonateViewState

protocol DonateViewModelLifeCycle: AnyObject {
    func set(delegate: DonateViewModelDelegate)
    func load()
}

@MainActor
protocol DonateViewInteraction: AnyObject {
    func handleActionEvent(_ event: DonateViewActionEvent)
}

protocol DonateViewState: AnyObject, ObservableObject {
    var paymentMethodsItems: [PaymentMethodViewItem] { get set }
}

protocol DonateViewModelDelegate: AnyObject {
    func didCopyPaymentMethod()
}
// MARK: - Model

// sourcery: AutoMockable
protocol DonateModelProtocol: AnyObject {
    func fetchPaymentMethods() async throws -> [DonateModel.PaymentMethod]
    func getPaymentMethod(for id: String) -> DonateModel.PaymentMethod?
    func fetchIconURL(for key: String) async throws -> URL?
}

// MARK: - Actions
enum DonateViewActionEvent {
    case back
    case tapOnCopyPaymentMethod(id: PaymentMethodViewItem.ID)
}
