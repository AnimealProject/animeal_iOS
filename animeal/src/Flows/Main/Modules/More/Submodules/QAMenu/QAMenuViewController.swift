import UIKit
import UIComponents
import SwiftUI
import Style

final class QAMenuViewController: UIHostingController<AnyView>, QAMenuViewable {
    // MARK: - UI properties
    private let viewModel: any QAMenuViewModelProtocol

    // MARK: - Initialization
    init(viewModel: any QAMenuViewModelProtocol) {
        self.viewModel = viewModel

        let model = (viewModel.observableModel as? QAMenuModel) ?? QAMenuModel()
        let designEngine: StyleEngine = StyleDefaultEngine()
        let qaMenuView = QAMenuView(model: model, interactionHandler: viewModel)
            .environmentObject(designEngine)

        super.init(rootView: AnyView(qaMenuView))
    }

    @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        view.backgroundColor = designEngine.colors.backgroundPrimary
        viewModel.load()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.backBarButtonItem = .back(target: self, action: #selector(barButtonItemTapped))
    }

    @objc private func barButtonItemTapped() {
        viewModel.handleActionEvent(.back)
    }
}
