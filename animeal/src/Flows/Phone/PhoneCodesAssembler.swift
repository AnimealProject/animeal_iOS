// System
import UIKit

// SDK
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

        view.modalPresentationStyle = .pageSheet

        if let sheet = view.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 16
            sheet.largestUndimmedDetentIdentifier = nil
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            view.isModalInPresentation = false
        }

        return view
    }
}
