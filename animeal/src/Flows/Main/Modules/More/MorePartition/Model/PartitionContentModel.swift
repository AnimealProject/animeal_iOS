import Foundation

// swiftlint:disable nesting
struct PartitionContentModel {
    let header: Header
    let content: Content
    let footer: Footer?

    struct Header {
        let title: String
    }

    struct Content {
        let actions: [Action]?
        let bottomTextBlock: TextBlock?

        init(actions: [Action]? = nil, bottomTextBlock: TextBlock? = nil) {
            self.actions = actions
            self.bottomTextBlock = bottomTextBlock
        }
    }

    struct TextBlock {
        let title: String
    }

    struct Footer {
        let action: Action
    }

    enum FooterType {
        case accent
        case inverted
    }

    struct Action {
        let actionId: ActionID
        let title: String
        let type: FooterType
        let dialog: Dialog?

        enum ActionID {
            case none
            case copyIBAN
        }
    }

    struct Dialog {
        let title: String
        let actions: [Action]

        struct Action {
            let actionId: ActionID
            let title: String
            let style: Style

            enum ActionID {
                case delete
                case logout
                case cancel
            }

            enum Style {
                case accent
                case inverted
            }
        }
    }
}
// swiftlint:enable nesting
