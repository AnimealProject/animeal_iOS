//
//  OnboardingStepCell.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import UIKit

protocol OnboardingStepCell where Self: UICollectionViewCell {
    static var reuseIdentifier: String { get }
}

final class OnboardingImageStepCell: UICollectionViewCell, OnboardingStepCell {
    // MARK: - Reuse Identifier
    static var reuseIdentifier: String { String(describing: Self.self) }

    // MARK: - UI properties
    private let stepView: OnboardingImageStepView = {
        let item = OnboardingImageStepView()
        item.translatesAutoresizingMaskIntoConstraints = false
        return item
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(_ model: OnboardingView.Step) {
        stepView.configure(
            OnboardingImageStepView.Model(
                identifier: model.identifier,
                image: model.image,
                title: model.title,
                text: model.text
            )
        )
    }

    // MARK: - Setup
    private func setup() {
        contentView.addSubview(stepView)
        stepView.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: 32.0
        ).isActive = true
        stepView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stepView.trailingAnchor.constraint(
            equalTo: trailingAnchor,
            constant: -32.0
        ).isActive = true
        stepView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
