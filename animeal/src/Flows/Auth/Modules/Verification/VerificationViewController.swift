// System
import UIKit

// SDK
import UIComponents

final class VerificationViewController: BaseViewController, VerificationViewModelOutput {
    // MARK: - UI properties
    private let headerView = TextBigTitleSubtitleView().prepareForAutoLayout()
    private let codeInputView = VerificationInputView().prepareForAutoLayout()
    private let resendView = TextClickableLeftIconTitleView().prepareForAutoLayout()

    // MARK: - Dependencies
    private let viewModel: VerificationCombinedViewModel

    // MARK: - Initialization
    init(viewModel: VerificationCombinedViewModel) {
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

    override func handleKeyboardNotification(keyboardData: KeyboardData) {
        super.handleKeyboardNotification(keyboardData: keyboardData)
        UIView.animate(
            withDuration: keyboardData.animationDuration,
            delay: 0.0,
            options: keyboardData.animationCurveOption
        ) {
            self.additionalSafeAreaInsets.bottom = keyboardData.keyboardRect.height
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - State
    func applyHeader(_ viewHeader: VerificationViewHeader) {
        headerView.configure(viewHeader.model)
    }

    func applyCode(_ viewCode: VerificationViewCode, _ applyDifference: Bool) {
        codeInputView.apply(viewCode.modelState)
        guard applyDifference else { return }
        codeInputView.configure(
            VerificationInputView.Model(
                code: viewCode.items.map { $0.model }
            )
        )
    }

    func applyResendCode(_ viewResendCode: VereficationViewResendCode) {
        resendView.configure(viewResendCode.model)
    }

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary.uiColor

        view.addSubview(headerView)
        headerView.leadingAnchor ~= view.safeAreaLayoutGuide.leadingAnchor + 32.0
        headerView.topAnchor ~= view.safeAreaLayoutGuide.topAnchor + 32.0
        headerView.trailingAnchor ~= view.safeAreaLayoutGuide.trailingAnchor - 32.0

        view.addSubview(codeInputView)
        codeInputView.leadingAnchor ~= headerView.leadingAnchor
        codeInputView.topAnchor ~= headerView.bottomAnchor + 32.0
        codeInputView.trailingAnchor ~= headerView.trailingAnchor

        view.addSubview(resendView)
        resendView.leadingAnchor >= headerView.leadingAnchor
        resendView.topAnchor >= codeInputView.bottomAnchor + 32.0
        resendView.trailingAnchor <= headerView.trailingAnchor
        resendView.centerXAnchor ~= view.safeAreaLayoutGuide.centerXAnchor
        resendView.topAnchor ~= view.safeAreaLayoutGuide.bottomAnchor - 32.0

        setupKeyboardHandling()
    }

    // MARK: - Binding
    private func bind() {
        codeInputView.onChange = { [weak self] items in
            self?.viewModel.handleActionEvent(
                VerificationViewActionEvent.changeCode(
                    items.map { $0.viewItem }
                )
            )
        }

        resendView.onClick = { [weak self] in
            self?.viewModel.handleActionEvent(
                VerificationViewActionEvent.tapResendCode
            )
        }

        viewModel.onHeaderHasBeenPrepared = { [weak self] viewHeader in
            self?.applyHeader(viewHeader)
        }
        viewModel.onCodeHasBeenPrepared = { [weak self] viewCode, applyDiff in
            self?.applyCode(viewCode, applyDiff)
        }
        viewModel.onResendCodeHasBeenPrepared = { [weak self] viewResendCode in
            self?.applyResendCode(viewResendCode)
        }
    }
}
