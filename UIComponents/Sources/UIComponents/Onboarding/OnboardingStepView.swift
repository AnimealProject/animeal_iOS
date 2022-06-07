//
//  OnboardingStepView.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import UIKit

extension OnboardingImageStepView {
    public struct Model {
        public let identifier: String
        public let image: UIImage?
        public let title: String
        public let text: String

        public init(
            identifier: String,
            image: UIImage?,
            title: String,
            text: String
        ) {
            self.identifier = identifier
            self.image = image
            self.title = title
            self.text = text
        }
    }
}

public final class OnboardingImageStepView: UIView {
    // MARK: - Private properties
    private let containerView: UIStackView = {
        let item = UIStackView()
        item.translatesAutoresizingMaskIntoConstraints = false
        item.axis = .vertical
        item.spacing = 16.0
        return item
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleView: UILabel = {
        let item = UILabel()
        item.translatesAutoresizingMaskIntoConstraints = false
        item.textColor = .black
        item.font = UIFont.systemFont(ofSize: 24.0)
        item.textAlignment = .center
        item.numberOfLines = 0
        return item
    }()

    private let textView: UILabel = {
        let item = UILabel()
        item.translatesAutoresizingMaskIntoConstraints = false
        item.textColor = .gray
        item.font = UIFont.systemFont(ofSize: 16.0)
        item.textAlignment = .center
        item.numberOfLines = 0
        return item
    }()

    // MARK: - Initialization
    public init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        imageView.image = model.image
        titleView.text = model.title
        textView.text = model.text
    }

    // MARK: - Setup
    private func setup() {
        addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        titleView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        textView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )

        containerView.addArrangedSubview(imageView)
        containerView.addArrangedSubview(titleView)
        containerView.addArrangedSubview(textView)
    }
}
