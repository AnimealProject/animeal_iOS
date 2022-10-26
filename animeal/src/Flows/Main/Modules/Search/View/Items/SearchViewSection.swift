import Foundation

public struct SearchViewSection {
    public var identifier: String
    public var items: [SearchViewItem]
    let header: SearchViewSupplementary?
    let footer: SearchViewSupplementary?
    let expanded: Bool

    public init(
        identifier: String,
        items: [SearchViewItem],
        header: SearchViewSupplementary? = nil,
        footer: SearchViewSupplementary? = nil,
        expanded: Bool = true
    ) {
        self.identifier = identifier
        self.items = items
        self.header = header
        self.footer = footer
        self.expanded = expanded
    }
}
