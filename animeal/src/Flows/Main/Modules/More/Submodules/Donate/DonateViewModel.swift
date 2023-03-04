import Foundation
import UIKit
import Style
import Common
import UniformTypeIdentifiers

final class DonateViewModel: DonateViewModelLifeCycle, DonateViewInteraction, DonateViewState,  ObservableObject {

    // MARK: - Dependencies
    private let model: DonateModelProtocol
    private let coordinator: MorePartitionCoordinatable
    private let mapper: DonatePaymentMethodViewMappable

    @Published var paymentMethodsItems: [PaymentMethodViewItem] = []

    // MARK: - Initialization
    init(
        model: DonateModelProtocol,
        coordinator: MorePartitionCoordinatable,
        mapper: DonatePaymentMethodViewMappable = DonatePaymentMethodViewMapper()
    ) {
        self.model = model
        self.coordinator = coordinator
        self.mapper = mapper
        setup()
    }

    // MARK: - Life cycle
    func setup() {
    }

    func load() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let methods = try await self.model.fetchPaymentMethods()
                self.paymentMethodsItems = methods.map { self.mapper.mapPaymentMethod($0, iconURL: nil) }
                await self.fetchIcons(for: methods)
            } catch {
                self.coordinator.displayAlert(message: error.localizedDescription)
            }
        }
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: DonateViewActionEvent) {
        switch event {
        case .back:
            coordinator.routeTo(.back)
        case .tapOnCopyPaymentMethod(let id):
            proceedPaymentMethod(id: id)
        }
    }
    
    // MARK: - Private
    
    private func proceedPaymentMethod(id: PaymentMethodViewItem.ID) {
        guard let paymentMethod = model.getPaymentMethod(for: id) else { return }
        UIPasteboard.general.setValue(paymentMethod.accountDetails, forPasteboardType: UTType.plainText.identifier)
    }

    private func fetchIcons(for methods: [DonateModel.PaymentMethod]) async {
        paymentMethodsItems = await methods.asyncMap { method in
            let iconURL: URL? = await {
                do { return try await model.fetchIconURL(for: method.icon) }
                catch { return nil }
            }()
            return mapper.mapPaymentMethod(method, iconURL: iconURL)
        }
    }
}
