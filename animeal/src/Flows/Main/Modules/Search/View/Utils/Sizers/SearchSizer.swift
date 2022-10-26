import UIKit

public protocol SearchCellSizer {
    init(item: SearchViewItem, availableWidth: CGFloat)
    func calculateSize() -> CGSize
}

public protocol SearchSupplementaryViewSizer {
    init(item: SearchViewSupplementary, availableWidth: CGFloat)
    func calculateSize() -> CGSize
}

public class SearchCellAutoSizer: SearchCellSizer {
    private let item: SearchViewItem
    private let autoSizer: AutoSizer

    required public init(item: SearchViewItem, availableWidth: CGFloat) {
        self.item = item
        self.autoSizer = AutoSizer(availableWidth: availableWidth)
    }

    public func calculateSize() -> CGSize {
        autoSizer.calculateSize { () -> (UIView) in
            let cell = item.cellType.init()
            cell.configure(item)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell.contentView
        }
    }
}

public class SearchSupplementaryViewAutoSizer: SearchSupplementaryViewSizer {
    private let item: SearchViewSupplementary
    private let autoSizer: AutoSizer

    required public init(item: SearchViewSupplementary, availableWidth: CGFloat) {
        self.item = item
        self.autoSizer = AutoSizer(availableWidth: availableWidth)
    }

    public func calculateSize() -> CGSize {
        autoSizer.calculateSize { () -> (UIView) in
            let view = item.viewType.init()
            view.configure(item)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            return view
        }
    }
}

private class AutoSizer {
    private let availableWidth: CGFloat

    private var heightCache: [UIContentSizeCategory: CGFloat] = [:]
    private var contentSizeCategory: UIContentSizeCategory {
        UIApplication.shared.preferredContentSizeCategory
    }

    init(availableWidth: CGFloat) {
        self.availableWidth = availableWidth
    }

    func calculateSize(with viewProvider: () -> (UIView)) -> CGSize {
        let cachedHeight = heightCache[contentSizeCategory]
        if let height = cachedHeight, height != 0 {
            return CGSize(width: availableWidth, height: height)
        }

        let view = viewProvider()
        view.layoutIfNeeded()
        let targetSize = CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height)
        let height = view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        ).height
        heightCache[contentSizeCategory] = height

        return CGSize(width: availableWidth, height: height)
    }
}
