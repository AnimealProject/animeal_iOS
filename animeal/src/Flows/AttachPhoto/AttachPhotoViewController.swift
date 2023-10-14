// System
import UIKit

// SDK
import UIComponents
import Style

final class AttachPhotoViewController: UIViewController, AttachPhotoViewable {
    // MARK: - Constants
    private enum Constants {
        static let itemWidth: CGFloat = 84.0
        static let itemHeight: CGFloat = 76.0
        static let offset: CGFloat = 20.0
    }

    // MARK: - UI properties
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let item = UICollectionView(frame: .zero, collectionViewLayout: layout)
            .prepareForAutoLayout()
        return item
    }()

    private lazy var attachingPhotoView: AttachPhotoView = {
        return AttachPhotoView(
            frame: view.bounds,
            collectionView: collectionView)
        .prepareForAutoLayout()
    }()

    // MARK: - Data source
    private lazy var dataSource: UICollectionViewDiffableDataSource<AttachPhotoViewSection, AttachPhotoViewItem> =
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return UICollectionViewCell() }
            return self.cell(collectionView, for: indexPath, itemIdentifier: itemIdentifier)
        }

    // MARK: - Dependencies
    private let viewModel: AttachPhotoViewModelProtocol

    // MARK: - Initialization
    init(viewModel: AttachPhotoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    // MARK: - State
    func applyContent(_ viewContent: AttachPhotoViewContent) {
        view.isHidden = false
        attachingPhotoView.configure(AttachPhotoView.Model(
            placeTitle: viewContent.placeTitle,
            placeImage: viewContent.placeImage,
            hintTitle: viewContent.hintTitle,
            buttonTitle: viewContent.buttonTitle,
            isActive: viewContent.isActive)
        )
    }

    func applySnapshot(_ snapshot: DataSourceSnapshot) {
        dataSource.apply(snapshot)
    }

    func updateContent(with state: Bool) {
        attachingPhotoView.configureFinishButtonStyle(state)
    }
}

extension AttachPhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
        else { return .zero }
        switch itemIdentifier {
        case .common:
            return CGSize(
                width: Constants.itemWidth,
                height: Constants.itemHeight
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return .zero
    }
}

private extension AttachPhotoViewController {
    // MARK: - Setup
    func setup() {
        view.isHidden = true
        view.addSubview(attachingPhotoView)
        attachingPhotoView.topAnchor ~= view.topAnchor
        attachingPhotoView.leftAnchor ~= view.leftAnchor + Constants.offset
        attachingPhotoView.rightAnchor ~= view.rightAnchor - Constants.offset
        attachingPhotoView.bottomAnchor ~= view.bottomAnchor

        collectionView.backgroundColor = designEngine.colors.backgroundPrimary
        collectionView.delegate = self
        collectionView.register(
            AttachPhotoViewCell.self,
            forCellWithReuseIdentifier: AttachPhotoViewCell.reuseIdentifier)
    }

    // MARK: - Bind
    func bind() {
        attachingPhotoView.onTapAttachPhoto = { [weak self] in
            if let granted = self?.viewModel.grantCameraPermission(),
                granted {
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.allowsEditing = true
                vc.delegate = self
                self?.present(vc, animated: true)
            }
        }

        attachingPhotoView.onTapFinishButton = { [weak self] in
            self?.viewModel.handleActionEvent(.finish)
        }
        viewModel.onContentHasBeenPrepared = { [weak self] viewContent in
            self?.applyContent(viewContent)
        }
        viewModel.onSnapshotHasBeenPrepared = { [weak self] viewSnapshot in
            self?.applySnapshot(viewSnapshot)
            self?.updateContent(with: !viewSnapshot.itemIdentifiers.isEmpty)
        }

        viewModel.onCameraPermissionCustomRequired = { [weak self] in
            Task {
                await self?.openSettings()
            }
        }

        viewModel.onAttachPhotoActionHaveBeenPrepared = { [weak self] action in
            self?.handleAttachPhotoAction(action)
        }

        viewModel.load()
    }

    // MARK: - Cell provider
    func cell(
        _ collectionView: UICollectionView,
        for indexPath: IndexPath,
        itemIdentifier: AttachPhotoViewItem
    ) -> UICollectionViewCell {
        switch itemIdentifier {
        case let .common(placeimage):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AttachPhotoViewCell.reuseIdentifier,
                for: indexPath) as? AttachPhotoViewCell else { return UICollectionViewCell() }

            let progressModel = viewModel.progressModel(for: placeimage)
            let cellModel = AttachPhotoViewCell.Model(image: placeimage, progressModel: progressModel)
            cell.configure(cellModel)
            cell.onTapCloseAction = { [weak self] in
                self?.viewModel.handleActionEvent(.removeImage(image: cellModel.image))
            }

            return cell
        }
    }
}

extension AttachPhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        self.viewModel.handleActionEvent(
            AttachPhotoViewActionEvent.addImage(image: image)
        )
        self.saveImage(imageTake: image)
    }
}

private extension AttachPhotoViewController {
    // MARK: - Save image
    func saveImage(imageTake: UIImage) {
        UIImageWriteToSavedPhotosAlbum(
            imageTake,
            self,
            #selector(image(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }

    // MARK: - Save Image callback
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Success")
        }
    }

    // MARK: - Open settings to update permissions
    func openSettings() async {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }

        await UIApplication.shared.open(url)
    }

    func handleAttachPhotoAction(_ action: AttachPhotoModel.AttachPhotoAction) {
        let alertViewController = AlertViewController(title: action.title)

        action.actions.forEach { attachPhotoAction in
            var actionHandler: (() -> Void)?
            switch attachPhotoAction.style {
            case .inverted:
                actionHandler = {
                    alertViewController.dismiss(animated: true)
                }
            case .accent(let action):
                actionHandler = { [weak self] in
                    guard let self = self else { return }
                    if action == .cameraAccess {
                        self.viewModel.handleActionEvent(.cameraAccess)
                    }
                    alertViewController.dismiss(animated: true)
                }
            }

            alertViewController.addAction(
                AlertAction(
                    title: attachPhotoAction.title,
                    style: attachPhotoAction.style.alertActionStyle,
                    handler: actionHandler
                )
            )
        }
        self.present(alertViewController, animated: true)
    }
}
