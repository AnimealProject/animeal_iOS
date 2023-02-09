import UIKit
import UIComponents
import SwiftUI

final class AboutViewController: UIViewController, AboutViewable {
    // MARK: - UI properties
    private let viewModel: any AboutViewModelProtocol

    // MARK: - Initialization
    init(viewModel: any AboutViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.load()
    }

    // MARK: - Setup
    private func setup() {
        setupNavigationBar()
        view.backgroundColor = designEngine.colors.backgroundPrimary

        guard let model = viewModel.observableModel as? AboutModel else {
            return
        }

        let aboutView = AboutView(model: model, interactionHandler: viewModel)
            .environmentObject(designEngine)

        let hostingViewController = UIHostingController(rootView: aboutView)

        view.addSubview(hostingViewController.view.prepareForAutoLayout())
        hostingViewController.view.leadingAnchor ~= view.safeAreaLayoutGuide.leadingAnchor
        hostingViewController.view.topAnchor ~= view.safeAreaLayoutGuide.topAnchor
        hostingViewController.view.trailingAnchor ~= view.safeAreaLayoutGuide.trailingAnchor
        hostingViewController.view.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor
        hostingViewController.view.backgroundColor = designEngine.colors.backgroundPrimary
    }

    private func setupNavigationBar() {
        navigationItem.backBarButtonItem = .back(target: self, action: #selector(barButtonItemTapped))
    }

    @objc private func barButtonItemTapped() {
        viewModel.handleActionEvent(.back)
    }
}
