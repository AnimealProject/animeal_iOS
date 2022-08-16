import Foundation

extension SegmentedControl {
    public struct Model {
        let items: [Item]

        public init(items: [Item]) {
            self.items = items
        }
    }

    public struct Item {
        public let identifier: Int
        public let title: String
        public let isSelected: Bool

        public init(
            identifier: Int,
            title: String,
            isSelected: Bool = false
        ) {
            self.identifier = identifier
            self.title = title
            self.isSelected = isSelected
        }
    }
}
