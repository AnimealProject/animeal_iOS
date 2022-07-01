import UIKit
import UIComponents

final class ProfileViewController: BaseViewController, ProfileViewModelOutput {

    // MARK: - UI properties
    private lazy var firstNameTextFieldView: TextFieldView = {
        return TextFieldView(
            model: TextFieldView.Model(
                description: L10n.Profile.name,
                placeholderText: L10n.Profile.name,
                defaultText: viewModel.userFirstName,
                textInputKind: .name
            ),
            delegate: self
        )
    }()

    private lazy var lastNameTextFieldView: TextFieldView = {
        return TextFieldView(
            model: TextFieldView.Model(
                description: L10n.Profile.surname,
                placeholderText: L10n.Profile.surname,
                defaultText: viewModel.userLastName,
                textInputKind: .name
            ),
            delegate: self
        )
    }()

    private lazy var emailTextFieldView: TextFieldView = {
        return TextFieldView(
            model: TextFieldView.Model(
                description: L10n.Profile.email,
                placeholderText: L10n.Profile.email,
                defaultText: viewModel.userEmail,
                textInputKind: .email
            ),
            delegate: self
        )
    }()

    private lazy var phoneTextFieldView: TextFieldView = {
        return TextFieldView(
            model: TextFieldView.Model(
                description: L10n.Profile.phoneNumber,
                defaultText: viewModel.processedPhoneNumber,
                isEnabled: false,
                textInputKind: .phone
            ),
            delegate: self
        )
    }()

    private lazy var calendarView: CalendarView = {
        return CalendarView(
            model: CalendarView.Model(
                description: L10n.Profile.birthDate,
                textFieldText: viewModel.formattedBirthdate
            ),
            datePickerView: datePickerView,
            delegate: self
        )
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
            primaryAction: .init(
                handler: { [weak self] _ in
                    self?.onDoneButtonDidTap()
                }
            )
        )
        button.backgroundColor = designEngine.colors.accentTint.uiColor
        button.tintColor = designEngine.colors.primary.uiColor
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
        view.backgroundColor = designEngine.colors.primary.uiColor

        let contentView = UIView().prepareForAutoLayout()

        let headerLabel = UILabel()
        headerLabel.font = designEngine.fonts.primary.bold(34.0).uiFont
        headerLabel.textColor = designEngine.colors.textSecondary.uiColor
        headerLabel.numberOfLines = 1
        headerLabel.text = L10n.Profile.header

        let descriptionLabel = UILabel()
        descriptionLabel.font = designEngine.fonts.primary.bold(16.0).uiFont
        descriptionLabel.textColor = designEngine.colors.textSecondary.uiColor
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
            self?.calendarView.setText(formattedDate)
        }
    }

    private func onDoneButtonDidTap() {
        viewModel.onDoneButtonDidTap()
    }
}

extension ProfileViewController: UITextFieldDelegate {
}
