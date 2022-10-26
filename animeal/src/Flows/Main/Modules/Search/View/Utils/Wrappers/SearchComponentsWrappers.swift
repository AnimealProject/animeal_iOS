import Foundation

struct SearchViewItemlWrapper: Hashable {
    let item: SearchViewItem

    var identifier: String { item.identifier }

    static func == (lhs: SearchViewItemlWrapper, rhs: SearchViewItemlWrapper) -> Bool {
        lhs.item.isEqual(to: rhs.item)
    }

    func hash(into hasher: inout Hasher) {
        item.hash(into: &hasher)
    }
}

struct SearchViewSectionWrapper: Hashable {
    private let _items: [SearchViewItemlWrapper]
    var items: [SearchViewItemlWrapper] {
        section.expanded ? _items : []
    }
    var identifier: String { section.identifier }

    let section: SearchViewSection

    init(section: SearchViewSection) {
        self.section = section
        self._items = section.items.map(SearchViewItemlWrapper.init)
    }

    public static func == (
        lhs: SearchViewSectionWrapper,
        rhs: SearchViewSectionWrapper
    ) -> Bool {
        guard lhs.identifier == rhs.identifier else {
            return false
        }

        return isModel(lhs.section.header, equalTo: rhs.section.header) &&
               isModel(lhs.section.footer, equalTo: rhs.section.footer) &&
               lhs.section.expanded == rhs.section.expanded &&
               lhs._items == rhs._items
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(section.expanded)

        _items.forEach { model in
            model.hash(into: &hasher)
        }
        section.header?.hash(into: &hasher)
        section.footer?.hash(into: &hasher)
    }

    private static func isModel(
        _ left: SearchViewSupplementary?,
        equalTo right: SearchViewSupplementary?
    ) -> Bool {
        if left == nil && right == nil {
            return true
        }

        if let left = left, let right = right {
            return left.isEqual(to: right)
        }

        return false
    }
}
