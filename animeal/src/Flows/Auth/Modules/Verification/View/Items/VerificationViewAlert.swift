import Foundation

struct ViewAlert {
    typealias Action = ViewAlertAction
    
    let title: String
    let actions: [Action]
}

struct ViewAlertAction {
    public enum Style {
        case accent
        case inverted
    }
    
    let title: String
    let style: Style
    let handler: () -> Void
}
