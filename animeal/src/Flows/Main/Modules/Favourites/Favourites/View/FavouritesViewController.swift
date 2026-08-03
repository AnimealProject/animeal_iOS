import UIKit
import UIComponents
import Style

final class FavouritesViewController: UIViewController {

    // MARK: - Private properties
    private let viewModel: FavouritesCombinedViewModel
    private let headerView = TableHeaderTextTitleView()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private lazy var emptyView = EmptyView()

    private enum ReloadButtonConstants {
        static let size: CGFloat = 44.0
    }

    private lazy var reloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Asset.Images.refreshIcon.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = designEngine.colors.accent
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var reloadView: UIView = {
        let container = UIView()
        container.addSubview(reloadButton.prepareForAutoLayout())
        reloadButton.centerXAnchor ~= container.centerXAnchor
        reloadButton.centerYAnchor ~= container.centerYAnchor
        reloadButton.widthAnchor ~= ReloadButtonConstants.size
        reloadButton.heightAnchor ~= ReloadButtonConstants.size
        return container
    }()

    private var _favouriteItems = [FavouriteItem]()
    var favouriteItems: [FavouriteItem] {
        get {
            return _favouriteItems
        }
        set {
            _favouriteItems = newValue

            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Initialization
    init(viewModel: FavouritesCombinedViewModel) {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    @objc private func reloadButtonTapped() {
        viewModel.load()
    }

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary

        headerView.configure(.init(title: L10n.Favourites.header, fontSize: 28))

        tableView.register(
            FavouriteItemCell.self,
            forCellReuseIdentifier: FavouriteItemCell.reuseIdentifier
        )
        tableView.register(
            FavouriteItemShimmerCell.self,
            forCellReuseIdentifier: FavouriteItemShimmerCell.reuseIdentifier
        )

        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        tableView.delegate = self
        tableView.dataSource = self

        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(tableView.prepareForAutoLayout())
        tableView.topAnchor ~= safeArea.topAnchor
        tableView.leadingAnchor ~= safeArea.leadingAnchor
        tableView.trailingAnchor ~= safeArea.trailingAnchor
        tableView.bottomAnchor ~= safeArea.bottomAnchor

        tableView.tableHeaderView = headerView
        headerView.prepareForAutoLayout()
        headerView.leadingAnchor ~= safeArea.leadingAnchor + 20.0
        headerView.centerXAnchor ~= tableView.centerXAnchor
        headerView.topAnchor ~= tableView.topAnchor

        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }
}

extension FavouritesViewController: FavouritesViewModelOutput {
    func populateFavourites(_ viewState: FavouriteViewContentState) {
        switch viewState {
        case .empty(let title):
            tableView.backgroundView = emptyView
            favouriteItems = []
            emptyView.configure(.init(title: title))
        case .content(let favourites):
            tableView.backgroundView = nil
            favouriteItems = favourites
        }
    }

    func applyFavouriteMediaContent(_ content: FavouriteMediaContent) {
        guard let itemIndex = favouriteItems.firstIndex(where: { item in
            item.feedingPointId == content.feedingPointId
        }) else { return }

        guard let cell = tableView.cellForRow(
            at: IndexPath(row: itemIndex, section: 0)
        ) as? FavouriteItemCell
        else { return }
        cell.setIcon(content.favouriteIcon)
    }

    func setLoading(_ isLoading: Bool) {
        tableView.isUserInteractionEnabled = !isLoading
    }

    func showReloadState() {
        tableView.backgroundView = reloadView
        favouriteItems = []
    }
}

extension FavouritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let item = favouriteItems[indexPath.row] as? FavouriteViewItem else { return }
        viewModel.handleActionEvent(.tapFeedingPoint(item.feedingPointId))
    }
}

extension FavouritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favouriteItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = favouriteItems[indexPath.row]
        guard let cell: FavouriteCell = tableView.dequeueReusableCell(
            withIdentifier: item.cellReuseIdentifier,
            for: indexPath
        ) as? FavouriteCell
        else { return UITableViewCell() }

        cell.configure(item)
        if let favouriteCell = cell as? FavouriteItemCell {
            favouriteCell.onTap = { [weak self] in
                self?.viewModel.handleActionEvent(.tapFavorite(item.feedingPointId))
            }
        }
        return cell
    }
}
