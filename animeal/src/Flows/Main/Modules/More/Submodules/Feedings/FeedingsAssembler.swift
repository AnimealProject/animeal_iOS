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
        let hostingViewController = UIHostingController(rootView: feedingView)

        return hostingViewController
    }
}
