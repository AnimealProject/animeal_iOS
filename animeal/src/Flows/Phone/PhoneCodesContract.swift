import UIKit

// MARK: - View
@MainActor
protocol PhoneCodesViewable: AnyObject {
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<PhoneCodesViewSection, PhoneCodesViewItem>

    func applyHeader(_ viewHeader: PhoneCodesViewHeader)
    func applySnapshot(_ snapshot: DataSourceSnapshot)
}

// MARK: - ViewModel
typealias PhoneCodesViewModelProtocol = PhoneCodesViewModelLifeCycle
    & PhoneCodesViewInteraction
    & PhoneCodesViewState

protocol PhoneCodesViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

@MainActor
protocol PhoneCodesViewInteraction: AnyObject {
    func handleActionEvent(_ event: PhoneCodesViewActionEvent)
}

@MainActor
protocol PhoneCodesViewState: AnyObject {
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<PhoneCodesViewSection, PhoneCodesViewItem>

    var onHeaderHasBeenPrepared: ((PhoneCodesViewHeader) -> Void)? { get set }
    var onSnapshotHasBeenPrepared: ((DataSourceSnapshot) -> Void)? { get set }
}
