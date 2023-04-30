//
//  ButtonContainerView.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import UIKit

public final class ButtonContainerView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let spacing: CGFloat = 28.0
        static let contentInsets: UIEdgeInsets =
            UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)
    }

    // MARK: - Private properties
    private let containerView: UIStackView = {
        let item = UIStackView()
        item.translatesAutoresizingMaskIntoConstraints = false
        item.axis = .vertical
        item.spacing = Constants.spacing
        item.distribution = .fillEqually
        return item
    }()

    // MARK: - Handlers
    public var onTap: ((String) -> Void)?

    // MARK: - Initialization
    public init(axis: NSLayoutConstraint.Axis = .vertical) {
        super.init(frame: CGRect.zero)
        self.containerView.axis = axis
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ content: [ButtonView]) {
        containerView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        content.forEach { item in
            item.onTap = { [weak self] identifier in
                self?.onTap?(identifier)
            }
        }
        content.forEach(containerView.addArrangedSubview)
    }

    // MARK: - Setup
    private func setup() {
        addSubview(containerView)

        containerView.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: Constants.contentInsets.left
        ).isActive = true
        containerView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: Constants.contentInsets.top
        ).isActive = true
        containerView.trailingAnchor.constraint(
            equalTo: trailingAnchor,
            constant: -Constants.contentInsets.right
        ).isActive = true
        containerView.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -Constants.contentInsets.bottom
        ).isActive = true
    }
}
