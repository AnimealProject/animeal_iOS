import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .first { $0.activationState == .foregroundActive && $0 is UIWindowScene }
            .flatMap { $0 as? UIWindowScene }?
            .windows
            .first(where: \.isKeyWindow)
    }
}
