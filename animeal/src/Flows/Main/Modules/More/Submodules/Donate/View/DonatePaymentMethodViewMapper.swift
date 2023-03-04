import Foundation
import Style
import UIComponents

// sourcery: AutoMockable
protocol DonatePaymentMethodViewMappable {
    func mapPaymentMethod(_ input: DonateModel.PaymentMethod, iconURL: URL?) -> PaymentMethodViewItem
}

final class DonatePaymentMethodViewMapper: DonatePaymentMethodViewMappable {
    func mapPaymentMethod(_ input: DonateModel.PaymentMethod, iconURL: URL?) -> PaymentMethodViewItem {
        PaymentMethodViewItem(
            id: input.id,
            name: input.name,
            details: input.accountDetails,
            iconURL: iconURL
        )
    }
}

struct PaymentMethodViewItem: Identifiable {
    let id: String
    let name: String
    let details: String
    let iconURL: URL?
}
