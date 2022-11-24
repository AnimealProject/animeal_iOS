import UIKit
import Style

public enum Toast {
    public struct Configuration {
        let hideDelay: TimeInterval

        public static var `default`: Configuration {
            return Configuration(hideDelay: 4)
        }
    }

    public static func show(
        message: String,
        anchor: UIView,
        configuration: Configuration = Configuration.default
    ) {
        let designEngine = UIView().designEngine

        let toastContainer = UIView()
        toastContainer.backgroundColor = designEngine.colors.backgroundPrimary.uiColor
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 24
        toastContainer.layer.masksToBounds = false
        toastContainer.shadow()

        let toastLabel = UILabel()
        toastLabel.textColor = designEngine.colors.textPrimary.uiColor
        toastLabel.textAlignment = .center
        toastLabel.font = designEngine.fonts.primary.medium(14).uiFont
        toastLabel.text = message


        toastContainer.addSubview(toastLabel.prepareForAutoLayout())
        toastLabel.leadingAnchor ~= toastContainer.leadingAnchor + 24
        toastLabel.trailingAnchor ~= toastContainer.trailingAnchor - 24
        toastLabel.topAnchor ~= toastContainer.topAnchor + 16
        toastLabel.bottomAnchor ~= toastContainer.bottomAnchor - 14

        anchor.addSubview(toastContainer.prepareForAutoLayout())
        toastLabel.centerXAnchor ~= anchor.centerXAnchor
        toastLabel.topAnchor ~= anchor.safeAreaLayoutGuide.topAnchor + 24

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: configuration.hideDelay, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}
