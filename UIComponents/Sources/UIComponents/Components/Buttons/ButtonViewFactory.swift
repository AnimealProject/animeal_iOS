import UIKit

public protocol ButtonViewGenerating {
    func makeSignInWithAppleButton() -> ButtonView
    func makeSignInWithFacebookButton() -> ButtonView
    func makeSignInWithMobileButton() -> ButtonView

    func makeMyLocationButton() -> ButtonView
}

public struct ButtonViewFactory: ButtonViewGenerating, StyleEngineContainable {
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 60.0
        static let cornerRadius: CGFloat = 30.0
        static let titleInsets: UIEdgeInsets =
            UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: -10.0)
    }

    // MARK: - Initialization
    public init() { }

    // MARK: - Creation
    public func makeSignInWithAppleButton() -> ButtonView {
        let button = UIButton()
        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true

        button.backgroundColor = designEngine.colors.textPrimary.uiColor
        button.setTitleColor(
            designEngine.colors.primary.uiColor,
            for: UIControl.State.normal
        )
        button.setTitleColor(
            designEngine.colors.textDescriptive.uiColor,
            for: UIControl.State.highlighted
        )
        button.titleEdgeInsets = Constants.titleInsets

        return ButtonView(contentView: button)
    }

    public func makeSignInWithFacebookButton() -> ButtonView {
        let button = UIButton()
        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true

        button.backgroundColor = designEngine.colors.secondaryAccentTint.uiColor
        button.setTitleColor(
            designEngine.colors.primary.uiColor,
            for: UIControl.State.normal
        )
        button.setTitleColor(
            designEngine.colors.textDescriptive.uiColor,
            for: UIControl.State.highlighted
        )
        button.titleEdgeInsets = Constants.titleInsets

        return ButtonView(contentView: button)
    }

    public func makeSignInWithMobileButton() -> ButtonView {
        let button = UIButton()
        button.layer.cornerRadius = Constants.cornerRadius
        button.clipsToBounds = true

        button.backgroundColor = designEngine.colors.accentTint.uiColor
        button.setTitleColor(
            designEngine.colors.primary.uiColor,
            for: UIControl.State.normal
        )
        button.setTitleColor(
            designEngine.colors.textDescriptive.uiColor,
            for: UIControl.State.highlighted
        )
        button.titleEdgeInsets = Constants.titleInsets

        return ButtonView(contentView: button)
    }

    public func makeMyLocationButton() -> ButtonView {
        let button = UIButton()
        button.backgroundColor = designEngine.colors.primary.uiColor
        return CircleButtonView(contentView: button)
    }
}
