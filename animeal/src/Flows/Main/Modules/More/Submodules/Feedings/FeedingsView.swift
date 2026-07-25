//
//  FeedingsView.swift
//  animeal
//
//  Created by Luka Alimbarashvili on 07.05.26.
//

import SwiftUI
import UIComponents
import Style

struct FeedingsView: View {
    var viewModel: FeedingsViewModel

    private let designEngine: StyleEngine = StyleDefaultEngine()

    private let tabs: [(title: String, status: FeedingStatus)] = [
        (L10n.Feedings.pending, .pending),
        (L10n.Feedings.approved, .approved),
        (L10n.Feedings.rejected, .rejected),
        (L10n.Feedings.outdated, .outdated)
    ]
    @State private var selectedTabTitle = L10n.Feedings.pending

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SegmentedView(
                items: tabs.map(\.title),
                selection: $selectedTabTitle
            )

            content

            Spacer()
        }
        .padding()
        .navigationTitle(L10n.Feedings.title)
        .task {
            await viewModel.loadAll()
        }
    }

    @ViewBuilder private var content: some View {
        let currentFeedingStatus = tabs.first { $0.title == selectedTabTitle }?.status ?? .pending
        let status = viewModel.tabStates[currentFeedingStatus]
        switch status {
        case .none:
            Text(L10n.Errors.somethingWrong.asBaseError().description)
                .foregroundColor(designEngine.colors.error.color)
        case .failed:
            Text(L10n.Errors.somethingWrong.asBaseError().description)
                .foregroundColor(designEngine.colors.error.color)
        case .isLoading:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .loaded(let items):
            FeedingsListView(items: items)
        }
    }
}
