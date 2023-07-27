import UIKit
import UIComponents
import Style

final class FeedingPointDetailsViewController: UIViewController, FeedingPointDetailsViewable {

    public enum Constants {
        static let stackSpacing: CGFloat = 16
    }

    // MARK: - Properties
    private let contentContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
        return stackView
    }()
    private let buttonContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private let feedingHistoryContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
        return stackView
    }()
    private let pointDetailsView = FeedingPointDetailsView()
    private var shimmerAdded = false

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

        viewModel.onFeedingHistoryHaveBeenPrepared = { [weak self] content in
            self?.applyFeedingHistoryContent(content)
        }

        viewModel.onMediaContentHaveBeenPrepared = { [weak self] content in
            self?.applyFeedingPointMediaContent(content)
        }

        viewModel.onFavoriteMutationFailed = { [weak self] in
            self?.applyFavoriteMutationFailed()
        }
        viewModel.onRequestLocationAccess = { [weak self] in
            self?.requestLocation()
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
        contentContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttonContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pointDetailsView.configure(
            FeedingPointDetailsView.Model(
                placeInfoViewModel: content.placeInfo,
                isHighlighted: content.isFavorite
            )
        )
        pointDetailsView.didTapOnFavorite = { [weak self] in
            self?.viewModel.handleActionEvent(.tapFavorite)
        }
        contentContainer.addArrangedSubview(pointDetailsView)

        let paragraphView = TextParagraphView()
        contentContainer.addArrangedSubview(paragraphView)
        paragraphView.configure(content.placeDescription)

        if !self.viewModel.historyInitialized && !self.shimmerAdded {
            let feedingHistoryShimmerView = FeedingHistoryShimmerView()
            feedingHistoryContainer.addArrangedSubview(feedingHistoryShimmerView)
            feedingHistoryShimmerView.startAnimation(scheduler: viewModel.shimmerScheduler)
            self.shimmerAdded = true
        }

        contentContainer.addArrangedSubview(feedingHistoryContainer)

        contentContainer.addArrangedSubview(UIView())

        if let model = viewModel.showOnMapAction {
            let button = ButtonViewFactory().makeTextButton()
            button.configure(model)
            button.onTap = { [weak self] _ in
                self?.viewModel.handleActionEvent(.tapShowOnMap)
            }
            contentContainer.addArrangedSubview(button)
        }

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

    func applyFeedingHistoryContent(
        _ content: FeedingPointDetailsViewMapper.FeedingPointFeeders
    ) {
        feedingHistoryContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if !content.feeders.isEmpty {
            let title = TextTitleView()
            title.configure(TextTitleView.Model(title: content.title))
            feedingHistoryContainer.addArrangedSubview(title)

            content.feeders.forEach { feeder in
                let view = FeederView()
                view.configure(
                    FeederView.Model(
                        title: feeder.name,
                        subtitle: feeder.lastFeeded,
                        icon: Asset.Images.feederPlaceholderIcon.image
                    )
                )
                feedingHistoryContainer.addArrangedSubview(view)
            }
        }
    }

    func requestLocation() {
        let title = L10n.Feeding.Alert.grantLocationPermission
        let actions: [FeedingActionMapper.FeedingAction.Action] = [
            .init(title: L10n.Action.noThanks, style: .inverted),
            .init(title: L10n.Action.openSettings, style: .accent(.locationAccess))
        ]

        let alertViewController = AlertViewController(title: title)
        actions.forEach { feedingAction in
            var actionHandler: (() -> Void)?
            switch feedingAction.style {
            case .inverted:
                actionHandler = {
                    alertViewController.dismiss(animated: true)
                }
            case .accent:
                actionHandler = { [weak self] in
                    alertViewController.dismiss(animated: true)
                    Task {
                        await self?.openSettings()
                    }
                }
                alertViewController.addAction(
                    AlertAction(
                        title: feedingAction.title,
                        style: feedingAction.style.alertActionStyle,
                        handler: actionHandler
                    )
                )
            }
            self.present(alertViewController, animated: true)
        }
    }

    func openSettings() async {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }

        await UIApplication.shared.open(url)
    }
}
