// System
import UIKit

// SDK
import UIComponents

final class SearchViewController: UIViewController, SearchViewable {
    // MARK: - UI properties
    private let searchInputView = SearchInputView().prepareForAutoLayout()

    private let collectionViewLayout: UICollectionViewLayout = {
        let item = UICollectionViewFlowLayout()
        item.scrollDirection = .vertical
        return item
    }()

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).prepareForAutoLayout()

    private lazy var dataSource: UICollectionViewDiffableDataSource<
        SearchViewSectionWrapper, SearchViewItemlWrapper
    > = {
        let item = UICollectionViewDiffableDataSource<SearchViewSectionWrapper, SearchViewItemlWrapper>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, itemIdentifier in
            self?.cell(collectionView, for: indexPath, itemIdentifier: itemIdentifier)
        }
        item.supplementaryViewProvider = { [weak self] collectionView, elementKind, indexPath in
            self?.supplementary(collectionView, elementKind: elementKind, for: indexPath)
        }

        return item
    }()

    private lazy var emptyView = EmptyView()

    // MARK: - Dependencies
    private let viewModel: SearchViewModelProtocol

    // MARK: - Initialization
    init(viewModel: SearchViewModelProtocol) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    // MARK: - State
    func applyContentState(_ viewContentState: SearchViewContentState) {
        switch viewContentState {
        case .snapshot(let viewSnapshot):
            collectionView.backgroundView = nil
            dataSource.apply(viewSnapshot)
        case .empty(let viewEmpty):
            collectionView.backgroundView = emptyView
            emptyView.configure(.init(title: viewEmpty.text))
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return .zero }
        let sizer = itemIdentifier.item.cellSizerType.init(
            item: itemIdentifier.item,
            availableWidth: collectionView.frame.width
        )
        return sizer.calculateSize()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let sectionIdentifier = dataSource.sectionIdentifier(for: section)
        else { return .zero }

        guard let headerItem = sectionIdentifier.section.header
        else { return .zero }

        let sizer = headerItem.sizerType.init(
            item: headerItem,
            availableWidth: collectionView.frame.width
        )

        return sizer.calculateSize()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifer = dataSource.itemIdentifier(for: indexPath)
        else { return }
        viewModel.handleActionEvent(
            .itemDidTap(itemIdentifer.identifier)
        )
    }
}

private extension SearchViewController {
    // MARK: - Setup
    private func setup() {
        setupSearchView()
        setupCollectionView()
    }

    private func setupSearchView() {
        view.addSubview(searchInputView)
        searchInputView.leadingAnchor ~= view.leadingAnchor + 30.0
        searchInputView.topAnchor ~= view.safeAreaLayoutGuide.topAnchor + 16.0
        searchInputView.trailingAnchor ~= view.trailingAnchor - 30.0

        searchInputView.didChange = { [weak self] textInput in
            self?.viewModel.handleTextEvent(.didChange(textInput.text))
        }
        searchInputView.shouldReturn = { [weak self] _ in
            self?.view.endEditing(true)
            return true
        }
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.leadingAnchor ~= view.leadingAnchor
        collectionView.topAnchor ~= searchInputView.bottomAnchor
        collectionView.trailingAnchor ~= view.trailingAnchor
        collectionView.bottomAnchor ~= view.bottomAnchor
        collectionView.contentInset.bottom = 32.0

        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(
            SearchPointCell.self,
            forCellWithReuseIdentifier: SearchPointCell.reuseIdentifier
        )
        collectionView.register(
            SearchPointShimmerCell.self,
            forCellWithReuseIdentifier: SearchPointShimmerCell.reuseIdentifier
        )
        collectionView.register(
            SearchSupplementaryExpandableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchSupplementaryExpandableView.reuseIdentifier
        )
        collectionView.register(
            SearchSupplementaryShimmerView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchSupplementaryShimmerView.reuseIdentifier
        )

        collectionView.delegate = self
    }

    // MARK: - Bind
    private func bind() {
        viewModel.onContentStateWasPrepared = { [weak self] viewContentState in
            self?.applyContentState(viewContentState)
        }
        viewModel.onSearchInputWasPrepared = { [weak self] viewSearch in
            self?.searchInputView.configure(viewSearch)
        }

        viewModel.setup()
    }

    // MARK: - Supplementary provider
    func supplementary(
        _ collectionView: UICollectionView,
        elementKind: String,
        for indexPath: IndexPath
    ) -> UICollectionReusableView? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section)
            else { return UICollectionReusableView() }

            guard
                let headerItem = sectionIdentifier.section.header,
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: headerItem.viewReuseIdentifier,
                    for: indexPath
                ) as? SearchSupplementaryContainable
            else { return UICollectionReusableView() }
            headerView.configure(headerItem)
            headerView.onTap = { [weak self] in
                self?.viewModel.handleActionEvent(
                    .sectionDidTap(sectionIdentifier.identifier)
                )
            }
            return headerView
        default:
            return UICollectionReusableView()
        }
    }

    // MARK: - Cell provider
    func cell(
        _ collectionView: UICollectionView,
        for indexPath: IndexPath,
        itemIdentifier: SearchViewItemlWrapper
    ) -> UICollectionViewCell? {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: itemIdentifier.item.cellReuseIdentifier,
                for: indexPath
            ) as? SearchCellContainable
        else { return nil }
        cell.configure(itemIdentifier.item)
        return cell
    }
}
