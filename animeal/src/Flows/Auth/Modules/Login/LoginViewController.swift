//
//  LoginViewController.swift
//  animeal
//
//  Created by Диана Тынкован on 1.06.22.
//

// System
import UIKit

// SDK
import UIComponents

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

    // MARK: - State
    func applyOnboarding(_ onboardingSteps: [LoginViewOnboardingStep]) {
        onboardingView.configure(
            OnboardingView.Model(
                steps: onboardingSteps.map { $0.onboardingViewStepModel }
            )
        )
    }

    func applyActions(_ actions: [LoginViewAction]) {
        buttonsView.configure(
            actions.map { $0.buttonView }
        )
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

        view.addSubview(buttonsView)
        buttonsView.topAnchor.constraint(equalTo: onboardingView.bottomAnchor).isActive = true
        buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        buttonsView.onTap = { [weak self] identifier in
            self?.viewModel.handleActionEvent(
                LoginViewActionEvent.tapInside(identifier)
            )
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
        viewModel.onErrorIsNeededToDisplay = { [weak self] viewError in
            self?.displayError(viewError)
        }
    }
}
