import Foundation

struct SearchModelSection {
    let identifier: String
    let title: String
    var items: [SearchModelItem]
    var expanded: Bool

    mutating func toogle() {
        let oldValue = expanded
        expanded = !oldValue
    }
}

extension Array where Element == SearchModelSection {
    static var `default`: [SearchModelSection] { [] }
}
