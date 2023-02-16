import UIKit
import UIComponents
import SwiftUI

final class FeedingFinishedViewController: UIViewController, FeedingFinishedViewable {
    // MARK: - UI properties
    private let viewModel: FeedingFinishedViewModelProtocol

    // MARK: - Initialization
    init(viewModel: FeedingFinishedViewModelProtocol) {
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
        guard let model = viewModel.observableModel as? FeedingFinishedModel else {
            return
        }

        let aboutView = FeedingFinishedView(model: model, interactionHandler: viewModel)
            .environmentObject(designEngine)

        let hostingViewController = UIHostingController(rootView: aboutView)

        view.addSubview(hostingViewController.view.prepareForAutoLayout())
        hostingViewController.view.leadingAnchor ~= view.leadingAnchor
        hostingViewController.view.topAnchor ~= view.topAnchor
        hostingViewController.view.trailingAnchor ~= view.trailingAnchor
        hostingViewController.view.bottomAnchor ~= view.bottomAnchor
        hostingViewController.view.backgroundColor = designEngine.colors.backgroundPrimary
    }
}
