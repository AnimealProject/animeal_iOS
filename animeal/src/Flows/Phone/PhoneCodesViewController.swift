// System
import UIKit

// SDK
import UIComponents

final class PhoneCodesViewController: UIViewController, PhoneCodesViewable {
    // MARK: - Constants
    private enum Constants {
        static let itemHeight: CGFloat = 58.0
        static let offset: CGFloat = 16.0
        static let collectionTopOffset: CGFloat = 8.0
    }

    // MARK: - UI properties
    private let headerView = TextBigTitleSubtitleView().prepareForAutoLayout()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let item = UICollectionView(frame: .zero, collectionViewLayout: layout)
            .prepareForAutoLayout()
        return item
    }()

    // MARK: - Data source
    private lazy var dataSource: UICollectionViewDiffableDataSource<PhoneCodesViewSection, PhoneCodesViewItem> =
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return UICollectionViewCell() }
            return self.cell(collectionView, for: indexPath, itemIdentifier: itemIdentifier)
        }

    // MARK: - Dependencies
    private let viewModel: PhoneCodesViewModelProtocol

    // MARK: - Initialization
    init(viewModel: PhoneCodesViewModelProtocol) {
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
    func applyHeader(_ viewHeader: PhoneCodesViewHeader) {
        headerView.configure(
            TextBigTitleSubtitleView.Model(
                title: viewHeader.title,
                subtitle: nil
            )
        )
    }

    func applySnapshot(_ snapshot: DataSourceSnapshot) {
        dataSource.apply(snapshot)
    }
}

extension PhoneCodesViewController: UICollectionViewDelegateFlowLayout {
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
                width: collectionView.frame.width,
                height: Constants.itemHeight
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
        else { return }
        viewModel.handleActionEvent(
            PhoneCodesViewActionEvent.itemWasTapped(
                identifier: itemIdentifier.identifier
            )
        )
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

private extension PhoneCodesViewController {
    // MARK: - Setup
    func setup() {
        view.addSubview(headerView)
        headerView.leadingAnchor ~= view.leadingAnchor + Constants.offset
        headerView.topAnchor ~= view.topAnchor + Constants.offset
        headerView.trailingAnchor ~= view.trailingAnchor - Constants.offset

        view.addSubview(collectionView)
        collectionView.leadingAnchor ~= headerView.leadingAnchor
        collectionView.topAnchor ~= headerView.bottomAnchor + Constants.collectionTopOffset
        collectionView.trailingAnchor ~= headerView.trailingAnchor
        collectionView.bottomAnchor ~= view.bottomAnchor
        collectionView.contentInset.bottom = Constants.offset

        collectionView.delegate = self
        collectionView.register(
            PhoneCodesViewCommonCell.self,
            forCellWithReuseIdentifier: PhoneCodesViewCommonCell.reuseIdentifier
        )
    }

    // MARK: - Bind
    func bind() {
        viewModel.onHeaderHasBeenPrepared = { [weak self] viewHeader in
            self?.applyHeader(viewHeader)
        }
        viewModel.onSnapshotHasBeenPrepared = { [weak self] viewSnapshot in
            self?.applySnapshot(viewSnapshot)
        }

        viewModel.load()
    }

    // MARK: - Cell provider
    func cell(
        _ collectionView: UICollectionView,
        for indexPath: IndexPath,
        itemIdentifier: PhoneCodesViewItem
    ) -> UICollectionViewCell {
        switch itemIdentifier {
        case let .common(identifier, isSelected, flag, code):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhoneCodesViewCommonCell.reuseIdentifier,
                for: indexPath
            ) as? PhoneCodesViewCommonCell
            else { return UICollectionViewCell() }
            cell.configure(
                PhoneCodesViewCommonCell.Model(
                    identifier: identifier,
                    icon: flag,
                    title: code,
                    isSelected: isSelected
                )
            )
            return cell
        }
    }
}
