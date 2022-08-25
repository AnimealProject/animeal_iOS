//
//  ButtonView.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import UIKit
import Common

public extension ButtonView {
    struct Model {
        public let identifier: String
        public let viewType: ButtonView.Type
        public let icon: UIImage?
        public let title: String

        public init(
            identifier: String,
            viewType: ButtonView.Type,
            icon: UIImage?,
            title: String = String.empty
        ) {
            self.identifier = identifier
            self.viewType = viewType
            self.icon = icon
            self.title = title
        }
    }
}

open class ButtonView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 60.0
    }

    // MARK: - Private properties
    public let contentView: UIButton

    // MARK: - Public properties
    public var identifier: String
    public var onTap: ((String) -> Void)?

    // MARK: - Initialization
    public init(contentView: UIButton) {
        self.contentView = contentView
        self.identifier = UUID().uuidString
        super.init(frame: CGRect.zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        identifier = model.identifier
        contentView.setTitle(model.title, for: UIControl.State.normal)
        contentView.setImage(model.icon, for: UIControl.State.normal)
    }

    // MARK: - Setup
    public func setup() {
        addSubview(contentView.prepareForAutoLayout())
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: Constants.height).isActive = true

        contentView.addTarget(
            self,
            action: #selector(buttonWasPressed(_:)),
            for: UIControl.Event.touchUpInside
        )
    }

    // MARK: - Action handlers
    @objc public func buttonWasPressed(_ sender: UIButton) {
        onTap?(identifier)
    }
}
