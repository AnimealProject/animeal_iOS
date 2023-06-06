// System
import UIKit

// SDK
import UIComponents
import Common

@MainActor
enum PhoneCodesAssembler {
    static func assemble(
        selectedRegion: Region?,
        handler: @escaping (Region) async -> Void,
        completion: (() -> Void)?
    ) -> UIViewController {
        let viewModel = PhoneCodesViewModel(
            selectedRegion: selectedRegion,
            handler: handler,
            completion: completion
        )
        let view = PhoneCodesViewController(viewModel: viewModel)

        let presentationController = BottomSheetPresentationController(
            controller: view,
            configuration: .fullScreen
        )
        presentationController.modalPresentationStyle = .overFullScreen

        return presentationController
    }
}
