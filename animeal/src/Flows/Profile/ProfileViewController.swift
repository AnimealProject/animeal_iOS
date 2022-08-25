import UIKit
import UIComponents
import Style

final class ProfileViewController: BaseViewController, ProfileViewModelOutput {
    // MARK: - UI properties
    private lazy var firstNameTextFieldView: DefaultInputView = {
        let item = DefaultInputView().prepareForAutoLayout()
        item.configure(
            DefaultInputView.Model(
                identifier: UUID().uuidString,
                title: L10n.Profile.name,
                state: .normal,
                content: DefaultTextContentView.Model(
                    placeholder: L10n.Profile.name,
                    text: viewModel.userFirstName
                )
            )
        )
        return item
    }()

    private lazy var lastNameTextFieldView: DefaultInputView = {
        let item = DefaultInputView().prepareForAutoLayout()
        item.configure(
            DefaultInputView.Model(
                identifier: UUID().uuidString,
                title: L10n.Profile.surname,
                state: .normal,
                content: DefaultTextContentView.Model(
                    placeholder: L10n.Profile.surname,
                    text: viewModel.userLastName
                )
            )
        )
        return item
    }()

    private lazy var emailTextFieldView: DefaultInputView = {
        let item = DefaultInputView().prepareForAutoLayout()
        item.configure(
            DefaultInputView.Model(
                identifier: UUID().uuidString,
                title: L10n.Profile.email,
                state: .normal,
                content: DefaultTextContentView.Model(
                    placeholder: L10n.Profile.email,
                    text: viewModel.userEmail
                )
            )
        )
        return item
    }()

    private lazy var phoneTextFieldView: DefaultInputView = {
        let item = DefaultInputView().prepareForAutoLayout()
        item.configure(
            DefaultInputView.Model(
                identifier: UUID().uuidString,
                title: L10n.Profile.phoneNumber,
                state: .normal,
                content: DefaultTextContentView.Model(
                    placeholder: L10n.Profile.phoneNumber,
                    text: viewModel.processedPhoneNumber
                )
            )
        )
        return item
    }()

    private lazy var calendarView: DefaultInputView = {
        let item = DefaultInputView().prepareForAutoLayout()
        item.configure(
            DefaultInputView.Model(
                identifier: UUID().uuidString,
                title: L10n.Profile.birthDate,
                state: .normal,
                content: DefaultTextContentView.Model(
                    placeholder: L10n.Profile.birthDate,
                    text: viewModel.formattedBirthdate,
                    rightActions: [
                        .init(identifier: UUID().uuidString, icon: Asset.Images.calendar.image, action: { identifier in
                            print(identifier)
                        })
                    ]
                )
            )
        )
        item.inputView = datePickerView
        return item
    }()

    private lazy var datePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.locale = .current
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(onBirthdateDidChange), for: .valueChanged)
        return datePicker
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(
            frame: .zero,
            primaryAction: .init { [weak self] _ in
                self?.onDoneButtonDidTap()
            }
        )
        button.backgroundColor = designEngine.colors.accent.uiColor
        button.tintColor = designEngine.colors.backgroundPrimary.uiColor
        button.titleLabel?.font = designEngine.fonts.primary.bold(16.0).uiFont
        button.layer.cornerRadius = 30.0
        button.clipsToBounds = true
        button.setTitle(L10n.Profile.done, for: .normal)
        return button
    }()

    // MARK: - Dependencies
    private let viewModel: ProfileViewModelProtocol

    // MARK: - Initialization
    init(viewModel: ProfileViewModelProtocol) {
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
        setupKeyboardHandling()
    }

    // MARK: - Setup
    override func handleKeyboardNotification(keyboardData: KeyboardData) {
        UIView.animate(
            withDuration: keyboardData.animationDuration,
            delay: 0.0,
            options: keyboardData.animationCurveOption
        ) {
            self.additionalSafeAreaInsets.bottom = keyboardData.keyboardRect.height
            self.view.layoutIfNeeded()
        }
    }

    private func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary.uiColor

        let contentView = UIView().prepareForAutoLayout()

        let headerLabel = UILabel()
        headerLabel.font = designEngine.fonts.primary.bold(34.0).uiFont
        headerLabel.textColor = designEngine.colors.textPrimary.uiColor
        headerLabel.numberOfLines = 1
        headerLabel.text = L10n.Profile.header

        let descriptionLabel = UILabel()
        descriptionLabel.font = designEngine.fonts.primary.bold(16.0).uiFont
        descriptionLabel.textColor = designEngine.colors.textPrimary.uiColor
        descriptionLabel.numberOfLines = 1
        descriptionLabel.text = L10n.Profile.subHeader

        let headerStackView = UIStackView(
            arrangedSubviews: [
                headerLabel,
                descriptionLabel
            ]
        )
        headerStackView.axis = .vertical
        headerStackView.spacing = 16.0

        let textfieldStackView = UIStackView(
            arrangedSubviews: [
                firstNameTextFieldView,
                lastNameTextFieldView,
                emailTextFieldView,
                phoneTextFieldView,
                calendarView
            ]
        )
        textfieldStackView.spacing = 32.0
        textfieldStackView.axis = .vertical

        let scrollView = UIScrollView().prepareForAutoLayout()

        contentView.addSubview(headerStackView.prepareForAutoLayout())
        contentView.addSubview(textfieldStackView.prepareForAutoLayout())
        contentView.addSubview(doneButton.prepareForAutoLayout())
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)

        scrollView.topAnchor ~= view.safeAreaLayoutGuide.topAnchor
        scrollView.leadingAnchor ~= view.safeAreaLayoutGuide.leadingAnchor
        scrollView.trailingAnchor ~= view.safeAreaLayoutGuide.trailingAnchor
        scrollView.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor

        contentView.topAnchor ~= scrollView.topAnchor
        contentView.leadingAnchor ~= scrollView.leadingAnchor
        contentView.trailingAnchor ~= scrollView.trailingAnchor
        contentView.bottomAnchor ~= scrollView.bottomAnchor
        contentView.widthAnchor ~= scrollView.widthAnchor

        headerStackView.topAnchor ~= contentView.topAnchor + 57.0
        headerStackView.leadingAnchor ~= contentView.leadingAnchor + 26.0
        headerStackView.trailingAnchor ~= contentView.trailingAnchor - 26.0

        textfieldStackView.topAnchor ~= headerStackView.bottomAnchor + 28.0
        textfieldStackView.leadingAnchor ~= scrollView.leadingAnchor + 26.0
        textfieldStackView.trailingAnchor ~= scrollView.trailingAnchor - 26.0

        doneButton.topAnchor ~= textfieldStackView.bottomAnchor + 52.0
        doneButton.trailingAnchor ~= contentView.trailingAnchor - 26.0
        doneButton.heightAnchor ~= 60.0
        doneButton.widthAnchor ~= 181.0
        doneButton.bottomAnchor ~= contentView.bottomAnchor - 55.0
    }

    // MARK: - Handlers
    @objc private func onBirthdateDidChange() {
        viewModel.setUserBirthdate(datePickerView.date) { [weak self] formattedDate in
            self?.calendarView.configure(
                DefaultInputView.Model(
                    identifier: UUID().uuidString,
                    title: L10n.Profile.birthDate,
                    state: .normal,
                    content: DefaultTextContentView.Model(
                        placeholder: L10n.Profile.birthDate,
                        text: formattedDate,
                        rightActions: [
                            .init(
                                identifier: UUID().uuidString,
                                icon: Asset.Images.calendar.image,
                                action: { identifier in
                                    print(identifier)
                                }
                            )
                        ]
                    )
                )
            )
        }
    }

    private func onDoneButtonDidTap() {
        viewModel.onDoneButtonDidTap()
    }
}
