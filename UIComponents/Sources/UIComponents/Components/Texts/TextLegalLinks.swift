//
//  TextLegalLinks.swift
//  UIComponents
//
//  Created by Sebastián Fernández on 9/4/25.
//
import UIKit

// MARK: - Model
public extension TextLegalLinksRow {
    struct Model {
        public let leftButtonModel: ButtonView.Model
        public let rightButtonModel: ButtonView.Model

        public init(leftButtonModel: ButtonView.Model, rightButtonModel: ButtonView.Model) {
            self.leftButtonModel = leftButtonModel
            self.rightButtonModel = rightButtonModel
        }
    }
}

public final class TextLegalLinksRow: UIView {

    private let leftButton = TextButtonView(contentView: UIButton())
    private let rightButton = TextButtonView(contentView: UIButton())

    // Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Configure with Model
    public func configure(with model: Model) {
        // Create button models for Terms & Conditions and Privacy Policy
        leftButton.configure(model.leftButtonModel)
        rightButton.configure(model.rightButtonModel)

        leftButton.onTap = { [weak self] identifier in
            self?.onTap?(identifier)
        }

        rightButton.onTap = { [weak self] identifier in
            self?.onTap?(identifier)
        }
    }

    // MARK: - Private Properties
    public var onTap: ((String) -> Void)?

    private func setupViews() {
        // Add buttons to the view
        addSubview(leftButton)
        addSubview(rightButton)
    }

    private func setupConstraints() {
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Position the left button
            leftButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftButton.topAnchor.constraint(equalTo: topAnchor),
            leftButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Position the right button
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightButton.topAnchor.constraint(equalTo: topAnchor),
            rightButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
