import UIKit

protocol Starting {
    func start()
}

final class Coordinator: Starting {

    // MARK: - Instance Properties
    private weak var startVC: UIViewController?

    // MARK: - Dependencies
    private let navigator: Navigating
    private let completion: (() -> Void)?

    // MARK: - Initializers

    init(
        navigator: Navigating,
        completion: (() -> Void)?
    ) {
        self.navigator = navigator
        self.completion = completion
    }

    // MARK: - Instance Methods

    func start() {
//        showFirstScreen()
    }

    // MARK: - Example
//    private func showFirstScreen() {
//        let firstVC = FirstAssembler.assemble(
//            nextButtonHandler: { [weak self] in
//                self?.showSecondScreen()
//            },
//            closeButtonHandler: { [weak self] in
//                self?.completion?()
//            }
//        )
//
//        navigator.push(firstVC, animated: true, completion: nil)
//        startVC = firstVC
//    }
//
//    private func showSecondScreen() {
//        let secondVC = SecondAssembler.assemble(
//            nextButtonHandler: { [weak self] in
//                self?.completion?()
//            }
//        )
//
//        navigator.push(secondVC, animated: true, completion: nil)
//    }

    @objc private func dismissPresentedVC() {
        navigator.topViewController?.dismiss(animated: true, completion: nil)
    }
}
