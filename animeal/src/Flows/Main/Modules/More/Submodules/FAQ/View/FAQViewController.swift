import UIKit
import UIComponents
import SwiftUI

final class FAQViewController<ViewModel: FAQViewModelProtocol>: UIViewController, FAQViewable {
    // MARK: - UI properties
    private let viewModel: ViewModel

    // MARK: - Initialization
    init(viewModel: ViewModel) {
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

        let contentView = FAQView(viewModel: viewModel)
            .environmentObject(designEngine)

        let hostingViewController = UIHostingController(rootView: contentView)

        view.addSubview(hostingViewController.view.prepareForAutoLayout())
        hostingViewController.view.leadingAnchor ~= view.leadingAnchor
        hostingViewController.view.topAnchor ~= view.topAnchor
        hostingViewController.view.trailingAnchor ~= view.trailingAnchor
        hostingViewController.view.bottomAnchor ~= view.bottomAnchor
        hostingViewController.view.backgroundColor = designEngine.colors.backgroundPrimary
    }

    private func setupNavigationBar() {
        navigationItem.backBarButtonItem = .back(target: self, action: #selector(barButtonItemTapped))
    }

    @objc private func barButtonItemTapped() {
        viewModel.handleActionEvent(.back)
    }
}
