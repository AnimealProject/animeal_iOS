// System
import UIKit

// SDK
import Common
import Style
import UIComponents
import Services

final class AttachPhotoViewModel: AttachPhotoViewModelProtocol {

    // MARK: - Properties
    private var snapshot = DataSourceSnapshot()
    private let viewSection = AttachPhotoViewSection.main
    private var placeTitle: String?
    private var photos: [UIImage: ProgressViewModel] = [:]
    private var coordinator: AttachPhotoCoordinatable & AttachPhotoCoordinatorEventHandlerProtocol

    // MARK: - Dependencies
    private let model: AttachPhotoModelProtocol
    private let contentMapper: AttachPhotoViewMappable
    private let cameraService: CameraServiceProtocol

    // MARK: - State
    var onContentHasBeenPrepared: ((AttachPhotoViewContent) -> Void)?
    var onSnapshotHasBeenPrepared: ((DataSourceSnapshot) -> Void)?
    var onCameraPermissionCustomRequired: (() -> Void)?
    var onAttachPhotoActionHaveBeenPrepared: ((AttachPhotoModel.AttachPhotoAction) -> Void)?

    // MARK: - Initialization
    public init(
        model: AttachPhotoModelProtocol,
        contentMapper: AttachPhotoViewMappable,
        coordinator: AttachPhotoCoordinatable & AttachPhotoCoordinatorEventHandlerProtocol,
        cameraService: CameraServiceProtocol = AppDelegate.shared.context.cameraService
    ) {
        self.model = model
        self.contentMapper = contentMapper
        self.coordinator = coordinator
        self.cameraService = cameraService
    }

    // MARK: - Life cycle
    func setup() { }

    func load() {
        fetchContent()
        createSnapshot()
    }

    func grantCameraPermission() -> Bool {
        return cameraService.grantCameraPermission { [weak self] in
            guard let self else { return }
            let action = self.model.fetchAttachPhotoAction(request: .cameraAccess)
            self.onAttachPhotoActionHaveBeenPrepared?(action)
        }
    }

    func progressModel(for image: UIImage) -> ProgressViewModel? {
        photos[image]
    }

    private func createSnapshot() {
        snapshot.appendSections([viewSection])
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: AttachPhotoViewActionEvent) {
        switch event {
        case .removeImage(let image):
            coordinator.routeTo(.deletePhoto(image: image))
            coordinator.deletePhotoEvent = { [weak self] in
                self?.updateSnapshot(with: .removeImage(image: image))
            }
        case .addImage(let image):
            updateSnapshot(with: .addImage(image: image))
        case .finish:
            let task = { [weak self] in
                guard let self else { return }
                do {
                    let keys = try await self.uploadAllMedia()
                    self.coordinator.routeTo(.finishFeeding(imageKeys: keys))
                } catch {
                    self.coordinator.displayAlert(message: error.localizedDescription)
                }
            }
            self.coordinator.displayActivityIndicator(waitUntil: task, completion: nil)
        case .cameraAccess:
            self.onCameraPermissionCustomRequired?()
        }
    }
}

private extension AttachPhotoViewModel {
    func updateSnapshot(with event: AttachPhotoViewActionEvent) {
        switch event {
        case .addImage(let image):
            let item = AttachPhotoViewItem.common(image: image)
            snapshot.appendItems([item], toSection: viewSection)
            photos[image] = ProgressViewModel(progress: 0, isVisible: false)
        case .removeImage(let image):
            let item = AttachPhotoViewItem.common(image: image)
            snapshot.deleteItems([item])
            photos.removeValue(forKey: image)
        case .finish:
            break
        case .cameraAccess:
            break
        }
        onSnapshotHasBeenPrepared?(snapshot)
    }

    private func uploadAllMedia() async throws -> [String] {
        return try await withThrowingTaskGroup(of: String.self) { [self] group in
            for (photo, progressModel) in self.photos {
                group.addTask {
                    try await self.uploadMedia(image: photo, progressModel: progressModel)
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }
    }

    private func uploadMedia(image: UIImage, progressModel: ProgressViewModel) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw L10n.Errors.somthingWrong.asBaseError()
        }
        defer {
            progressModel.isVisible = false
        }
        do {
            progressModel.isVisible = true
            return try await model.uploadMediaContent(data: data, progressListener: { progress in
                DispatchQueue.main.async {
                    progressModel.updateProgress(progress)
                }
            })
        } catch {
            progressModel.isVisible = false
            throw error
        }
    }

    private func fetchContent() {
        model.fetchFeedingPoints { [weak self] response in
            guard let self = self else { return }
            self.loadMediaContent(response.content.cover)
            self.placeTitle = self.contentMapper.mapFeedingPoint(response).name
        }
    }

    private func loadMediaContent(_ key: String?) {
        guard let key = key else { return }
        model.fetchMediaContent(key: key) { [weak self] content in
            guard let self = self else { return }

            if let mediaContent = self.contentMapper.mapFeedingPointMediaContent(content) {
                let image = mediaContent.placeIcon
                let viewContent = AttachPhotoViewContent(
                    placeTitle: self.placeTitle,
                    placeImage: image,
                    hintTitle: L10n.Attach.Photo.Hint.text,
                    buttonTitle: L10n.Action.finish,
                    isActive: false)

                self.onContentHasBeenPrepared?(viewContent)
            }
        }
    }
}
