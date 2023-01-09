import UIKit

// MARK: - View
@MainActor
protocol AttachPhotoViewable: AnyObject {
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<AttachPhotoViewSection, AttachPhotoViewItem>

    func applyContent(_ viewContent: AttachPhotoViewContent)
    func applySnapshot(_ snapshot: DataSourceSnapshot)
    func updateContent(with state: Bool)
}

// MARK: - ViewModel
typealias AttachPhotoViewModelProtocol = AttachPhotoViewModelLifeCycle
    & AttachPhotoViewInteraction
    & AttachPhotoViewState

protocol AttachPhotoViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

@MainActor
protocol AttachPhotoViewInteraction: AnyObject {
    func handleActionEvent(_ event: AttachPhotoViewActionEvent)
}

@MainActor
protocol AttachPhotoViewState: AnyObject {
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<AttachPhotoViewSection, AttachPhotoViewItem>

    var onContentHasBeenPrepared: ((AttachPhotoViewContent) -> Void)? { get set }
    var onSnapshotHasBeenPrepared: ((DataSourceSnapshot) -> Void)? { get set }
}


// MARK: - Model
// sourcery: AutoMockable
protocol AttachPhotoModelProtocol: AnyObject {
    func fetchFeedingPoints(_ completion: ((AttachPhotoModel.PointContent) -> Void)?)
    func fetchMediaContent(key: String, completion: ((Data?) -> Void)?)
}
