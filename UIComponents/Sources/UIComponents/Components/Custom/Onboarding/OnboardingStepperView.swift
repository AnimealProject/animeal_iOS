//
//  OnboardingStepperView.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import UIKit
import SwiftUI

extension OnboardingStepperView {
    struct Model {
        let numberOfSteps: Int
    }
}

final class OnboardingStepperView: UIView {
    // MARK: - Private properties
    private let pageIndicatorViewModel: PageIndicatorView.Model

    // MARK: - Initialization
    init() {
        self.pageIndicatorViewModel = PageIndicatorView.Model()
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(_ model: Model) {
        pageIndicatorViewModel.numberOfPages = model.numberOfSteps
    }

    func configureContentOffset(_ contentOffset: CGFloat) {
        pageIndicatorViewModel.contentOffset = contentOffset
    }

    func configureAvailableWidth(_ availableWidth: CGFloat) {
        pageIndicatorViewModel.availableWidth = availableWidth
    }

    // MARK: - Setup
    private func setup() {
        let pageIndicatorView = PageIndicatorView(model: self.pageIndicatorViewModel)
            .environmentObject(designEngine)
        let hostingViewController = UIHostingController(rootView: pageIndicatorView)

        addSubview(hostingViewController.view)
        hostingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        hostingViewController.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        hostingViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        hostingViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
