// System
import UIKit

// SDK
import Common

enum PhoneModelRequiredAction {
    typealias Picker = UIViewController
    typealias Completion = () -> Void

    struct OpenPickerComponents {
        let modelItem: ProfileModelItem
        let maker: @MainActor (Completion?) -> Picker?
    }

    case openPicker(OpenPickerComponents)
}

extension PhoneModelRequiredAction.OpenPickerComponents {
    static func phoneComponents(
        _ modelItem: ProfileModelItem,
        handler: @escaping (Region, Region) async -> Void
    ) -> Self {
        .init(modelItem: modelItem) { completion -> PhoneModelRequiredAction.Picker? in
            switch modelItem.type {
            case .phone(let region):
                return PhoneCodesAssembler.assemble(
                    selectedRegion: region,
                    handler: { selectedRegion in await handler(region, selectedRegion) },
                    completion: completion
                )
            default:
                return nil
            }
        }
    }
}
