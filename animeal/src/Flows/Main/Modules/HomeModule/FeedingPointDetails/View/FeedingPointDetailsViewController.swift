import UIKit
import UIComponents
import Style

final class FeedingPointDetailsViewController: UIViewController, FeedingPointDetailsViewable {
    // MARK: - Properties
    private let contentContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    private let buttonContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    // MARK: - Dependencies
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
        view.backgroundColor = designEngine.colors.backgroundPrimary.uiColor

        let pullBarView = UIView()
        pullBarView.backgroundColor = designEngine.colors.disabled.uiColor
        pullBarView.heightAnchor ~= 4
        pullBarView.widthAnchor ~= 18
        pullBarView.layer.cornerRadius = 2

        view.addSubview(pullBarView.prepareForAutoLayout())
        pullBarView.topAnchor ~= view.topAnchor + 12
        pullBarView.centerXAnchor ~= view.centerXAnchor

        view.addSubview(buttonContainer.prepareForAutoLayout())
        buttonContainer.leadingAnchor ~= view.leadingAnchor + 20
        buttonContainer.trailingAnchor ~= view.trailingAnchor - 20
        buttonContainer.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor

        let scrollView = UIScrollView()
        view.addSubview(scrollView.prepareForAutoLayout())
        scrollView.leadingAnchor ~= view.leadingAnchor
        scrollView.trailingAnchor ~= view.trailingAnchor
        scrollView.topAnchor ~= pullBarView.bottomAnchor + 8
        scrollView.bottomAnchor ~= buttonContainer.topAnchor

        scrollView.addSubview(contentContainer.prepareForAutoLayout())
        contentContainer.leadingAnchor ~= view.leadingAnchor + 20
        contentContainer.trailingAnchor ~= view.trailingAnchor - 20
        contentContainer.topAnchor ~= scrollView.topAnchor
        contentContainer.bottomAnchor ~= scrollView.bottomAnchor
    }

    func applyFeedingPointContent(_ content: FeedingPointDetailsViewItem) {
        let pointDetailsView = FeedingPointDetailsView()
        pointDetailsView.configure(
            FeedingPointDetailsView.Model(
                placeInfoViewModel: content.placeInfo,
                isHighlighted: false
            )
        )
        contentContainer.addArrangedSubview(pointDetailsView)

        let paragraphView = TextParagraphView()
        contentContainer.addArrangedSubview(paragraphView)
        paragraphView.configure(content.placeDescription)
        contentContainer.addArrangedSubview(UIView())

        let button = ButtonViewFactory().makeAccentButton()
        button.configure(content.action)
        button.onTap = { [weak self] _ in
            self?.viewModel.handleActionEvent(.tapAction)
        }
        buttonContainer.addArrangedSubview(button)
    }
}
