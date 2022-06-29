//
//  ButtonContainerView.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import UIKit

extension ButtonContainerView {
    public struct Model {
        public let buttons: [ButtonViewModel]

        public init(
            buttons: [ButtonViewModel]
        ) {
            self.buttons = buttons
        }
    }
}

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
        item.distribution = .equalSpacing
        return item
    }()

    // MARK: - Handlers
    public var onTap: ((String) -> Void)?

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
        containerView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let buttonViews = model.buttons.map { buttonModel -> ButtonView in
            let item = buttonModel.viewType.init()
            item.condifure(buttonModel)
            item.onTap = { [weak self] identifier in
                self?.onTap?(identifier)
            }
            return item
        }
        buttonViews.forEach(containerView.addArrangedSubview)
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
