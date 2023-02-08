import UIKit
import UIComponents
import Style

final class FeedingBookingViewController: UIViewController, FeedingBookingViewable {
    // MARK: - UI properties
    private let viewModel: FeedingBookingViewModelProtocol
    private let buttonContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 18
        return stackView
    }()

    // MARK: - Initialization
    init(viewModel: FeedingBookingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = designEngine.colors.backgroundPrimary
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
        view.addSubview(buttonContainer.prepareForAutoLayout())
        buttonContainer.leadingAnchor ~= view.leadingAnchor + 20
        buttonContainer.trailingAnchor ~= view.trailingAnchor - 20
        buttonContainer.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor - 20

        let contentView = UIView()
        view.addSubview(contentView.prepareForAutoLayout())
        contentView.leadingAnchor ~= view.leadingAnchor + 20
        contentView.trailingAnchor ~= view.trailingAnchor - 20
        contentView.topAnchor ~= view.topAnchor
        contentView.bottomAnchor ~= buttonContainer.topAnchor

        let topImageView = UIImageView(image: Asset.Images.attentionSign.image)
        contentView.addSubview(topImageView.prepareForAutoLayout())
        topImageView.topAnchor ~= contentView.topAnchor + 75
        topImageView.centerXAnchor ~= contentView.centerXAnchor

        let header = TextHeaderTitleView()
        header.configure(.init(title: L10n.Text.oneHourToFeed))
        contentView.addSubview(header.prepareForAutoLayout())
        header.centerXAnchor ~= contentView.centerXAnchor
        header.topAnchor ~= topImageView.bottomAnchor + 40

        let centerImageView = UIImageView(image: Asset.Images.bigDogAtBowlIcon.image)
        centerImageView.contentMode = .scaleAspectFit

        contentView.addSubview(centerImageView.prepareForAutoLayout())
        centerImageView.topAnchor ~= header.bottomAnchor + 65
        centerImageView.centerXAnchor ~= contentView.centerXAnchor
        centerImageView.bottomAnchor <= contentView.bottomAnchor - 100

        let cancelButton = ButtonViewFactory().makeAccentInvertedButton()
        cancelButton.configure(
            ButtonView.Model(
                identifier: UUID().uuidString,
                viewType: ButtonView.self,
                title: L10n.Action.cancel
            )
        )
        cancelButton.onTap = { [weak self] _ in
            self?.viewModel.handleActionEvent(.cancel)
        }
        buttonContainer.addArrangedSubview(cancelButton)

        let agreeButton = ButtonViewFactory().makeAccentButton()
        agreeButton.configure(
            ButtonView.Model(
                identifier: UUID().uuidString,
                viewType: ButtonView.self,
                title: L10n.Action.agree
            )
        )
        agreeButton.onTap = { [weak self] _ in
            self?.viewModel.handleActionEvent(.agree)
        }
        buttonContainer.addArrangedSubview(agreeButton)
    }
}
