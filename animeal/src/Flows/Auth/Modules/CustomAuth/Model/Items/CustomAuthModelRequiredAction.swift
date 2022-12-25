// System
import UIKit

// SDK
import Common

enum CustomAuthModelRequiredAction {
    typealias Picker = UIViewController
    typealias Completion = () -> Void

    struct OpenPickerComponents {
        let modelItem: CustomAuthModelItem
        let maker: @MainActor (Completion?) -> Picker?
    }

    case openPicker(OpenPickerComponents)
}

extension CustomAuthModelRequiredAction.OpenPickerComponents {
    static func phoneComponents(
        _ modelItem: CustomAuthModelItem,
        handler: @escaping (Region, Region) -> Void
    ) -> Self {
        .init(modelItem: modelItem) { completion -> CustomAuthModelRequiredAction.Picker? in
            switch modelItem.type {
            case .password:
                return nil
            case .phone(let region):
                return PhoneCodesAssembler.assemble(
                    selectedRegion: region,
                    handler: { selectedRegion in handler(region, selectedRegion) },
                    completion: completion
                )
            }
        }
    }
}
