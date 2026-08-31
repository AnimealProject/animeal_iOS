//
//  LoginViewController.swift
//  animeal
//
//  Created by Диана Тынкован on 1.06.22.
//

// System
import UIKit
import SafariServices

// SDK
import UIComponents
import Services
import Common

final class LoginViewController: UIViewController, LoginViewable {
    // MARK: - UI properties
    private let onboardingView: OnboardingView = {
        let item = OnboardingView()
        item.translatesAutoresizingMaskIntoConstraints = false
        return item
    }()

    private lazy var buttonsView: ButtonContainerView = {
        let item = ButtonContainerView()
        item.translatesAutoresizingMaskIntoConstraints = false
        item.backgroundColor = designEngine.colors.backgroundPrimary
        item.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        item.layer.cornerRadius = 30.0
        item.layer.shadowColor = designEngine.colors.textSecondary.cgColor
        item.layer.shadowOpacity = 0.2
        item.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        item.layer.shadowRadius = 4.0
        return item
    }()

    private let legalLinksRow = TextLegalLinksRow()

    // MARK: - Dependencies
    private let viewModel: LoginViewModelProtocol

    // MARK: - Initialization
    init(viewModel: LoginViewModelProtocol) {
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.shared.context.analyticsService.logEvent(
            ScreenViewEvent(
                screenName: AnalyticsScreen.screenForViewController(self).description,
                trackablePolicy: .multipleTracking,
                targets: [AnalyticsTargetType.firebase]
            )
        )
    }
    // MARK: - State
    func applyOnboarding(_ onboardingSteps: [LoginViewOnboardingStep]) {
        onboardingView.configure(
            OnboardingView.Model(
                steps: onboardingSteps.map { $0.onboardingViewStepModel }
            )
        )
    }

    func applyActions(_ actions: [LoginViewAction]) {
        var actionsStack: [UIView] = actions.map { $0.buttonView }

        let termsModel = ButtonView.Model(
            identifier: Constants.URLs.termsAndConditions,
            viewType: ButtonView.self,
            title: L10n.Action.termsAndConditions,
            accessibilityIdentifier: AccessibilityID.Auth.Login.termsAndConditions
        )

        let privacyModel = ButtonView.Model(
            identifier: Constants.URLs.privacyPolicy,
            viewType: ButtonView.self,
            title: L10n.Action.privacyPolicy,
            accessibilityIdentifier: AccessibilityID.Auth.Login.privacyPolicy
        )

        // Create and append a TextLegalLinksRow to the list of views
        legalLinksRow.configure(with: TextLegalLinksRow.Model(
            leftButtonModel: termsModel,
            rightButtonModel: privacyModel
        ))
        actionsStack.append(legalLinksRow)

        buttonsView.configure(actionsStack)
    }

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary

        view.addSubview(onboardingView)
        onboardingView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: 16.0
        ).isActive = true
        onboardingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        onboardingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        onboardingView.isUserInteractionEnabled = false

        view.addSubview(buttonsView)
        buttonsView.topAnchor.constraint(equalTo: onboardingView.bottomAnchor).isActive = true
        buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        buttonsView.onTap = { [weak self] identifier in
            self?.viewModel.handleActionEvent(LoginViewActionEvent.tapInside(identifier))
            self?.logLoginButtonTap(identifier)
        }
        legalLinksRow.onTap = { [weak self] identifier in
            self?.viewModel.handleActionEvent(LoginViewActionEvent.tapOnLegalLink(identifier))
        }
    }

    // MARK: - Binding
    private func bind() {
        viewModel.onOnboardingStepsHaveBeenPrepared = { [weak self] viewSteps in
            self?.applyOnboarding(viewSteps)
        }
        viewModel.onActionsHaveBeenPrepaped = { [weak self] viewActions in
            self?.applyActions(viewActions)
        }
        viewModel.onOpenWebPage = { [weak self] urlString in
            self?.openWebPage(with: urlString)
        }
    }

    private func logLoginButtonTap(_ identifier: String) {
        AppDelegate.shared.context.analyticsService.logEvent(
            UserInteractionEvent(
                eventName: identifier,
                screen: AnalyticsScreen.screenForViewController(self),
                trackablePolicy: .multipleTracking,
                targets: [AnalyticsTargetType.firebase]
            )
        )
    }

    private func openWebPage(with urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)") // Log anything unexpected
            return
        }

        // Create an SFSafariViewController instance
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemBlue
        present(safariVC, animated: true, completion: nil)
    }
}
