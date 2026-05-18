//
//  FeedingsView.swift
//  animeal
//
//  Created by Luka Alimbarashvili on 07.05.26.
//

import SwiftUI
import UIComponents

struct FeedingsView: View {
    private let tabs = ["Pending", "Approved", "Rejected", "Outdated"]
    @State private var selectedTab = "Pending"

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
        .navigationTitle("Feedings")
    }
}
