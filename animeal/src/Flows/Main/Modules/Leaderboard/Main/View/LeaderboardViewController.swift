//
//  LeaderboardViewController.swift
//  animeal
//
//  Created by Ilya Biltuev on 13.03.2023.
//

import UIKit

final class LeaderboardViewController: UIViewController {
    // MARK: - Private properties
    private let viewModel: LeaderboardViewModelProtocol

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
        
    }
}
