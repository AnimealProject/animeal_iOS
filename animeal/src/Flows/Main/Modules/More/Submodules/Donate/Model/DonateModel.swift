import Foundation
import Services

// MARK: - DonateModel
final class DonateModel: DonateModelProtocol {
    typealias Context = DefaultsServiceHolder & NetworkServiceHolder & DataStoreServiceHolder

    // MARK: - Private properties
    private let context: Context
    private let mapper: DonatePaymentMethodMappable
    
    private var paymentMethods: [PaymentMethod] = []

    // MARK: - Initialization
    init(context: Context = AppDelegate.shared.context,
         mapper: DonatePaymentMethodMappable = DonatePaymentMethodMapper()) {
        self.context = context
        self.mapper = mapper
    }
    
    func fetchPaymentMethods() async throws -> [DonateModel.PaymentMethod] {
        let methods = try await context.networkService.query(request: .list(animeal.BankAccount.self))
        self.paymentMethods = methods
            .map(mapper.mapPaymentMethod)
            .filter(\.enabled)
        return paymentMethods
    }
    
    func getPaymentMethod(for id: String) -> PaymentMethod? {
        paymentMethods.first(where: { $0.id == id })
    }
    
    func fetchIconURL(for key: String) async throws -> URL? {
        try await context.dataStoreService.getURL(key: key)
    }
}

extension DonateModel {
    struct PaymentMethod {
        let id: String
        let name: String
        let accountDetails: String
        let icon: String
        let enabled: Bool
    }
}
