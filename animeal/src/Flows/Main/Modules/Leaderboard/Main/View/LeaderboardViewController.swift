//
//  LeaderboardViewController.swift
//  animeal
//
//  Created by Ilya Biltuev on 13.03.2023.
//

import UIKit
import UIComponents

final class LeaderboardViewController: UIViewController {
    // MARK: - Private properties
    private let viewModel: LeaderboardViewModelProtocol
    private let headerView = TableHeaderTextTitleView()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private lazy var emptyView = EmptyView()

    // MARK: - Initialization
    init(viewModel: LeaderboardViewModelProtocol) {
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

    private func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary

        headerView.configure(.init(title: L10n.Favourites.header, fontSize: 28))

        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil

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

extension LeaderboardViewController: LeaderboardViewModelOutput {
    func populateLeaderboard(_ viewState: LeaderboardViewContentState) {
        switch viewState {
        case .empty(let title):
            tableView.backgroundView = emptyView
            emptyView.configure(.init(title: title))
        case .content:
            tableView.backgroundView = nil
        }
    }
}
