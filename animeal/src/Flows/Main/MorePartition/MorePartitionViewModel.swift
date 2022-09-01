import UIKit

final class MorePartitionViewModel: MorePartitionViewModelLifeCycle,
                                    MorePartitionViewInteraction,
                                    MorePartitionViewState {
    // MARK: - Dependencies
    private let model: MorePartitionModelProtocol
    private let mode: PartitionMode

    var onContentHaveBeenPrepared: ((PartitionContentModel) -> Void)?

    // MARK: - Initialization
    init(
        model: MorePartitionModelProtocol,
        mode: PartitionMode
    ) {
        self.model = model
        self.mode = mode
    }

    // MARK: - Life cycle
    func load() {
        let contentModel = model.fetchContentModel(mode)
        onContentHaveBeenPrepared?(contentModel)
    }
}
