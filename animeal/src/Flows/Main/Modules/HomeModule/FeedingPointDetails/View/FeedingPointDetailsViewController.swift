import UIKit
import UIComponents

final class FeedingPointDetailsViewController: UIViewController, FeedingPointDetailsViewable {
    // MARK: - properties
    private let viewModel: FeedingPointDetailsViewModelProtocol

    // MARK: - Initialization
    init(viewModel: FeedingPointDetailsViewModelProtocol) {
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
        let pullBarView = UIView()
        pullBarView.backgroundColor = designEngine.colors.disabled.uiColor
        pullBarView.heightAnchor ~= 4
        pullBarView.widthAnchor ~= 18
        pullBarView.layer.cornerRadius = 2

        view.addSubview(pullBarView.prepareForAutoLayout())
        pullBarView.topAnchor ~= view.topAnchor + 12
        pullBarView.centerXAnchor ~= view.centerXAnchor

        view.layer.cornerRadius = 30
        view.backgroundColor = designEngine.colors.backgroundPrimary.uiColor
    }
}
