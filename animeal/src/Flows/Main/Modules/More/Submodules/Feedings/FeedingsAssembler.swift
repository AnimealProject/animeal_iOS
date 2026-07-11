//
//  FeedingsAssembler.swift
//  animeal
//
//  Created by Luka Alimbarashvili on 07.05.26.
//

import SwiftUI
import Common

enum FeedingsAssembler {
    static func assemble(coordinator: MorePartitionCoordinatable) -> UIViewController {

        let viewModel = FeedingsViewModel(coordinator: coordinator)
        let view = UIHostingController(rootView: FeedingsView(viewModel: viewModel))

        return view
    }
}
