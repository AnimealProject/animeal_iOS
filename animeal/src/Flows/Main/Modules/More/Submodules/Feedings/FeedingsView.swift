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
    @ObservedObject var viewModel: FeedingsViewModel

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
        .task(id: selectedTabTitle) {
            guard let status = tabs.first(where: { $0.title == selectedTabTitle })?.status else { return }
            await viewModel.load(status: status)
        }
    }

    @ViewBuilder private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundColor(designEngine.colors.error.color)
        } else {
            List(viewModel.items) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.address)
                        .font(.body)
                    Text(item.date, style: .relative)
                        .font(.caption)
                        .foregroundColor(designEngine.colors.textSecondary.color)
                }
            }
            .listStyle(.plain)
        }
    }
}
