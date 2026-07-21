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
        let feedingView = FeedingsView(viewModel: viewModel)
            .environmentObject(StyleDefaultEngine())
        let hostingViewController = UIHostingController(rootView: feedingView)


        return hostingViewController
    }
}
