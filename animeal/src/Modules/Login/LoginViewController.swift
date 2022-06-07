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

final class LoginViewController: UIViewController, LoginViewModelOutput {
    // MARK: - UI properties
    private let onboardingView: OnboardingView = {
        let item = OnboardingView()
        item.translatesAutoresizingMaskIntoConstraints = false
        return item
    }()

    private let buttonsView: ButtonContainerView = {
        let item = ButtonContainerView()
        item.translatesAutoresizingMaskIntoConstraints = false
        item.backgroundColor = .white
        item.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        item.layer.cornerRadius = 30.0
        item.backgroundColor = UIColor.white
        item.layer.shadowColor = UIColor.black.cgColor
        item.layer.shadowOpacity = 0.09
        item.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        item.layer.shadowRadius = 4.0
        return item
    }()

    // MARK: - Dependencies
    private let viewModel: LoginCombinedViewModel

    // MARK: - Initialization
    init(viewModel: LoginCombinedViewModel) {
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
            ButtonContainerView.Model(
                buttons: actions.map { $0.buttonViewModel }
            )
        )
    }

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = UIColor.white

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
}
