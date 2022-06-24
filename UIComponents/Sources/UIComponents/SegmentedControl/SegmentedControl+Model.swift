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
        public let action: ((Int) -> Void)?

        public init(
            identifier: Int,
            title: String,
            action: ((Int) -> Void)?
        ) {
            self.identifier = identifier
            self.title = title
            self.action = action
        }
    }
}
