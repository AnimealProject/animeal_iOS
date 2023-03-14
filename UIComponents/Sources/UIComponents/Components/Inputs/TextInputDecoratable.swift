import UIKit

public protocol TextInputIdentifiable {
    var identifier: String { get }
}

public protocol TextInputDecoratable: UIView, TextFieldContentViewChangesHandable, TextInputIdentifiable { }

public enum TextInputView {
    public enum State {
        case normal
        case error(String?)
    }

    public struct Action {
        public let identifier: String
        public let icon: UIImage?
        public let action: ((String) -> Void)?

        public init(identifier: String, icon: UIImage?, action: ((String) -> Void)?) {
            self.identifier = identifier
            self.icon = icon
            self.action = action
        }
    }
}
