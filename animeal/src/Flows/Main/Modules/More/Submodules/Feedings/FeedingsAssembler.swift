//
//  FeedingsAssembler.swift
//  animeal
//
//  Created by Luka Alimbarashvili on 07.05.26.
//

import SwiftUI
import Common
import Style

enum FeedingsAssembler {
    static func assemble(coordinator: MorePartitionCoordinatable) -> UIViewController {
        let viewModel = FeedingsViewModel(coordinator: coordinator)
        let designEngine: StyleEngine = StyleDefaultEngine()
        let feedingView = FeedingsView(viewModel: viewModel)
            .environmentObject(designEngine)
        let hostingViewController = FeedingsHostingController(rootView: feedingView)

        return hostingViewController
    }
}

private final class FeedingsHostingController: UIHostingController<AnyView> {
    init(rootView: some View) {
        super.init(rootView: AnyView(rootView))
    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
