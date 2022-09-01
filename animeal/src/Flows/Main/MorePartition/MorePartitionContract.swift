import UIKit

// MARK: - View
protocol MorePartitionViewable: AnyObject {
    func applyContentModel(_ model: PartitionContentModel)
}

// MARK: - ViewModel
typealias MorePartitionViewModelProtocol = MorePartitionViewModelLifeCycle
    & MorePartitionViewInteraction
    & MorePartitionViewState

protocol MorePartitionViewModelLifeCycle: AnyObject {
    func load()
}

protocol MorePartitionViewInteraction: AnyObject {
}

protocol MorePartitionViewState: AnyObject {
    var onContentHaveBeenPrepared: ((PartitionContentModel) -> Void)? { get set }
}

// MARK: - Model
protocol MorePartitionModelProtocol: AnyObject {
    func fetchContentModel(_ mode: PartitionMode) -> PartitionContentModel
}
