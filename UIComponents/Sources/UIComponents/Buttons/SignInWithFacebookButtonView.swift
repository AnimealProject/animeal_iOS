//
//  SignInWithFacebookButtonView.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import UIKit

public final class SignInWithFacebookButtonView: UIView, ButtonView {
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 60.0
        static let cornerRadius: CGFloat = 30.0
        static let titleInsets: UIEdgeInsets =
            UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: -10.0)
    }

    // MARK: - Private properties
    private let button: UIButton = {
        let item = UIButton()
        item.translatesAutoresizingMaskIntoConstraints = false
        return item
    }()

    // MARK: - Public properties
    public var identifier: String
    public var onTap: ((String) -> Void)?

    // MARK: - Initialization
    public init() {
        self.identifier = UUID().uuidString
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func condifure(_ model: ButtonViewModel) {
        identifier = model.identifier
        button.setTitle(model.title, for: UIControl.State.normal)
        button.setImage(model.icon, for: UIControl.State.normal)
    }

    // MARK: - Setup
    private func setup() {
        addSubview(button)
        button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: Constants.height).isActive = true

        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true
        button.backgroundColor = UIColor(red: 67.0 / 255.0, green: 139.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setTitleColor(UIColor.lightGray, for: UIControl.State.highlighted)
        button.titleEdgeInsets = Constants.titleInsets
        button.addTarget(
            self,
            action: #selector(buttonWasPressed(_:)),
            for: UIControl.Event.touchUpInside
        )
    }

    // MARK: - Action handlers
    @objc private func buttonWasPressed(_ sender: UIButton) {
        onTap?(identifier)
    }
}
