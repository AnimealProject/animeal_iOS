import UIKit
import Style

public protocol ButtonViewGenerating {
    func makeSignInWithAppleButton() -> ButtonView
    func makeSignInWithMobileButton() -> ButtonView

    func makeMyLocationButton() -> ButtonView
}

public struct ButtonViewFactory: ButtonViewGenerating, StyleEngineContainable {
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 60.0
        static let cornerRadius: CGFloat = 30.0
        static let titleInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: -10.0)
    }

    // MARK: - Initialization
    public init() { }

    // MARK: - Creation
    public func makeSignInWithAppleButton() -> ButtonView {
        let button = UIButton()
        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true

        button.backgroundColor = designEngine.colors.alwaysDark
        button.titleLabel?.font = designEngine.fonts.primary.medium(16.0)
        button.setTitleColor(
            designEngine.colors.alwaysLight,
            for: UIControl.State.normal
        )
        button.setTitleColor(
            designEngine.colors.textSecondary,
            for: UIControl.State.highlighted
        )
        button.titleEdgeInsets = Constants.titleInsets

        return ButtonView(contentView: button)
    }

    public func makeSignInWithMobileButton() -> ButtonView {
        let button = UIButton()
        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true

        button.backgroundColor = designEngine.colors.accent
        button.titleLabel?.font = designEngine.fonts.primary.medium(16.0)
        button.setTitleColor(
            designEngine.colors.alwaysLight,
            for: UIControl.State.normal
        )
        button.setTitleColor(
            designEngine.colors.textSecondary,
            for: UIControl.State.highlighted
        )
        button.titleEdgeInsets = Constants.titleInsets

        return ButtonView(contentView: button)
    }

    public func makeSignInWithGuestButton() -> ButtonView {
        let button = UIButton()
        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true
        button.layer.borderColor = designEngine.colors.accent.cgColor
        button.layer.borderWidth = 1

        button.backgroundColor = designEngine.colors.backgroundPrimary
        button.titleLabel?.font = designEngine.fonts.primary.bold(16.0)
        button.setTitleColor(
            designEngine.colors.accent,
            for: UIControl.State.normal
        )
        button.setTitleColor(
            designEngine.colors.accent.withAlphaComponent(0.5),
            for: UIControl.State.highlighted
        )
        button.titleEdgeInsets = Constants.titleInsets

        return ButtonView(contentView: button)
    }

    public func makeAccentButton() -> ButtonView {
        let button = UIButton()
        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true

        button.backgroundColor = designEngine.colors.accent
        button.titleLabel?.font = designEngine.fonts.primary.bold(16.0)
        button.setTitleColor(
            designEngine.colors.alwaysLight,
            for: UIControl.State.normal
        )
        button.setTitleColor(
            designEngine.colors.textSecondary,
            for: UIControl.State.highlighted
        )

        return ButtonView(contentView: button)
    }

    public func makeAccentInvertedButton() -> ButtonView {
        let button = UIButton()
        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true
        button.layer.borderColor = designEngine.colors.accent.cgColor
        button.layer.borderWidth = 1

        button.backgroundColor = designEngine.colors.backgroundPrimary
        button.titleLabel?.font = designEngine.fonts.primary.bold(16.0)
        button.setTitleColor(
            designEngine.colors.accent,
            for: UIControl.State.normal
        )
        button.setTitleColor(
            designEngine.colors.accent.withAlphaComponent(0.5),
            for: UIControl.State.highlighted
        )

        return ButtonView(contentView: button)
    }

    public func makeDisabledButton() -> ButtonView {
        let button = UIButton()
        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true
        button.isUserInteractionEnabled = false

        button.backgroundColor = designEngine.colors.disabled
        button.titleLabel?.font = designEngine.fonts.primary.bold(16.0)
        button.setTitleColor(
            designEngine.colors.alwaysLight,
            for: UIControl.State.normal
        )

        return ButtonView(contentView: button)
    }

    public func makeMyLocationButton() -> ButtonView {
        let button = UIButton()
        button.backgroundColor = designEngine.colors.backgroundPrimary
        return CircleButtonView(contentView: button)
    }

    public func makeTextButton() -> ButtonView {
        TextButtonView(contentView: UIButton(type: .system))
    }
    
    public func makeArrowButton() -> ButtonView {
        let button = UIButton().apply(style: .arrowIcon)
        return ButtonView(contentView: button, height: 16)
    }
}

private extension Style where Component == UIButton {
    static var arrowIcon: Style<UIButton> {
        .init { button in
            let designEngine = button.designEngine
            
            button.setTitle(nil, for: .normal)
            button.backgroundColor = .clear
            button.tintColor = designEngine.colors.textPrimary
            button.imageView?.contentMode = .scaleAspectFit
            
            let font = designEngine.fonts.primary.bold(16) ?? .systemFont(ofSize: 16, weight: .bold)
            button.setPreferredSymbolConfiguration(.init(font: font), forImageIn: .normal)
        }
    }
}
