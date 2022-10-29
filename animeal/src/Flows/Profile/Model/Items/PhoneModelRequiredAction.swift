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
        handler: @escaping (Region) -> Void
    ) -> Self {
        .init(modelItem: modelItem) { completion -> PhoneModelRequiredAction.Picker? in
            switch modelItem.type {
            case .phone(let region):
                return PhoneCodesAssembler.assemble(
                    selectedRegion: region,
                    handler: handler,
                    completion: completion
                )
            default:
                return nil
            }
        }
    }
}
