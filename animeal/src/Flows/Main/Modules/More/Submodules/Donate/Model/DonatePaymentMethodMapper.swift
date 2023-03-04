import Foundation

// sourcery: AutoMockable
protocol DonatePaymentMethodMappable {
    func mapPaymentMethod(_ input: animeal.BankAccount) -> DonateModel.PaymentMethod
}

final class DonatePaymentMethodMapper: DonatePaymentMethodMappable {
    func mapPaymentMethod(_ input: animeal.BankAccount) -> DonateModel.PaymentMethod {
        DonateModel.PaymentMethod(
            id: input.id,
            name: input.name,
            accountDetails: input.value,
            icon: input.cover,
            enabled: input.enabled
        )
    }
}
