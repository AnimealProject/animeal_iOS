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

    @EnvironmentObject private var style: StyleEngine

    private let tabs: [(title: String, status: FeedingStatus)] = [
        (L10n.Feedings.pending, .pending),
        (L10n.Feedings.approved, .approved),
        (L10n.Feedings.rejected, .rejected),
        (L10n.Feedings.outdated, .outdated)
    ]
    @State private var selectedTabTitle = L10n.Feedings.pending
    @State private var itemPendingRejection: FeedingListItem?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 24) {
                backButton
                titleText

                SegmentedView(
                    items: tabs.map(\.title),
                    selection: $selectedTabTitle
                )

                content

                Spacer()
            }
            .padding()
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await viewModel.loadAll()
            }

            if let item = itemPendingRejection {
                rejectionPopup(for: item)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: itemPendingRejection != nil)
    }

    private func rejectionPopup(for item: FeedingListItem) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    itemPendingRejection = nil
                }

            FeedingRejectionReasonAlert(
                onCancel: {
                    itemPendingRejection = nil
                },
                onReject: { reason in
                    Task {
                        await viewModel.reject(item, reason: reason)
                        itemPendingRejection = nil
                    }
                }
            )
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Asset.Colors.backgroundPrimary.swiftUIColor)
            )
            .padding(.horizontal, 24)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private var backButton: some View {
        Button {
            viewModel.goBack()
        } label: {
            Image(asset: Asset.Images.arrowBackOffset)
                .foregroundColor(style.colors.textPrimary.color)
        }
    }

    private var titleText: some View {
        Text(L10n.Feedings.title)
            .font(style.fonts.primary.bold(28).font)
            .foregroundColor(style.colors.textPrimary.color)
    }

    @ViewBuilder private var content: some View {
        let currentFeedingStatus = tabs.first { $0.title == selectedTabTitle }?.status ?? .pending
        let status = viewModel.tabStates[currentFeedingStatus]
        switch status {
        case .none:
            Text(L10n.Errors.somethingWrong.asBaseError().description)
                .foregroundColor(style.colors.error.color)
        case .failed:
            Text(L10n.Errors.somethingWrong.asBaseError().description)
                .foregroundColor(style.colors.error.color)
        case .isLoading:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .loaded(let items):
            FeedingsListView(
                items: items,
                onApprove: { item in
                    Task {
                        await viewModel.approve(item)
                    }
                },
                onReject: { item in
                    Task {
                        itemPendingRejection = item
                    }
                }
            )
        }
    }
}
