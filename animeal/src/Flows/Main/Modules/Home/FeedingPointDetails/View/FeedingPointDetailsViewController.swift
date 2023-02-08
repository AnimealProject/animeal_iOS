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
    private let pointDetailsView = FeedingPointDetailsView()

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
        bind()
        viewModel.load()
    }

    // MARK: - Binding
    private func bind() {
        viewModel.onContentHaveBeenPrepared = { [weak self] content in
            self?.applyFeedingPointContent(content)
        }

        viewModel.onMediaContentHaveBeenPrepared = { [weak self] content in
            self?.applyFeedingPointMediaContent(content)
        }

        viewModel.onFavoriteMutationFailed = { [weak self] in
            self?.applyFavoriteMutationFailed()
        }
    }

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary

        let pullBarView = UIView()
        pullBarView.backgroundColor = designEngine.colors.disabled
        pullBarView.heightAnchor ~= 4
        pullBarView.widthAnchor ~= 18
        pullBarView.layer.cornerRadius = 2

        view.addSubview(pullBarView.prepareForAutoLayout())
        pullBarView.topAnchor ~= view.topAnchor + 12
        pullBarView.centerXAnchor ~= view.centerXAnchor

        view.addSubview(buttonContainer.prepareForAutoLayout())
        buttonContainer.leadingAnchor ~= view.leadingAnchor + 20
        buttonContainer.trailingAnchor ~= view.trailingAnchor - 20
        buttonContainer.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor - 20

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

    func applyFeedingPointMediaContent(
        _ content: FeedingPointDetailsViewMapper.FeedingPointMediaContent
    ) {
        pointDetailsView.setIcon(content.pointDetailsIcon)
    }

    func applyFavoriteMutationFailed() {
        pointDetailsView.toggleHighlightState()
    }

    func applyFeedingPointContent(
        _ content: FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem
    ) {
        pointDetailsView.configure(
            FeedingPointDetailsView.Model(
                placeInfoViewModel: content.placeInfo,
                isHighlighted: content.isFavorite
            )
        )
        pointDetailsView.onTap = { [weak self] in
            self?.viewModel.handleActionEvent(.tapFavorite)
        }
        contentContainer.addArrangedSubview(pointDetailsView)

        let paragraphView = TextParagraphView()
        contentContainer.addArrangedSubview(paragraphView)
        paragraphView.configure(content.placeDescription)

        if !content.feedingPointFeeders.feeders.isEmpty {
            let title = TextTitleView()
            title.configure(TextTitleView.Model(title: content.feedingPointFeeders.title))
            contentContainer.addArrangedSubview(title)

            content.feedingPointFeeders.feeders.forEach { feeder in
                let view = FeederView()
                view.configure(
                    FeederView.Model(
                        title: feeder.name,
                        subtitle: feeder.lastFeeded,
                        icon: Asset.Images.feederPlaceholderIcon.image
                    )
                )
                contentContainer.addArrangedSubview(view)
            }
        }

        contentContainer.addArrangedSubview(UIView())

        var button: ButtonView
        if content.action.isEnabled {
            button = ButtonViewFactory().makeAccentButton()
            button.onTap = { [weak self] _ in
                self?.viewModel.handleActionEvent(.tapAction)
            }
        } else {
            button = ButtonViewFactory().makeDisabledButton()
        }
        button.configure(content.action.model)
        buttonContainer.addArrangedSubview(button)
    }
}
