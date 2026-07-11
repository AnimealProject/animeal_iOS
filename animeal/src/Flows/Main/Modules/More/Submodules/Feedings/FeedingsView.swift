//
//  FeedingsView.swift
//  animeal
//
//  Created by Luka Alimbarashvili on 07.05.26.
//

import SwiftUI
import UIComponents

struct FeedingsView: View {
    let viewModel: FeedingsViewModel

    private let tabs = [
        L10n.Feedings.pending,
        L10n.Feedings.approved,
        L10n.Feedings.rejected,
        L10n.Feedings.outdated
    ]
    @State private var selectedTab = L10n.Feedings.pending

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SegmentedView(
                items: tabs,
                selection: $selectedTab
            )

            Text(selectedTab)
                .font(.headline)

            Spacer()
        }
        .padding()
        .navigationTitle(L10n.Feedings.title)
    }
}
