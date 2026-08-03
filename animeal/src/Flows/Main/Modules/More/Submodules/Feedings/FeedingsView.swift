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
    static let previewTabs: [(title: String, status: FeedingStatus)] = [
        (L10n.Feedings.pending, .pending),
        (L10n.Feedings.approved, .approved),
        (L10n.Feedings.rejected, .rejected),
        (L10n.Feedings.outdated, .outdated)
    ]

    var viewModel: FeedingsViewModel

    @EnvironmentObject private var style: StyleEngine

    private let tabs = FeedingsView.previewTabs
    @State private var selectedTabTitle = L10n.Feedings.pending
    @State private var itemPendingRejection: FeedingListItem?
    @State private var selectedItem: FeedingListItem?

    private var currentFeedingStatus: FeedingStatus {
        tabs.first { $0.title == selectedTabTitle }?.status ?? .pending
    }

    var body: some View {
        ZStack {
            FeedingsScreenContent(
                tabs: tabs,
                selectedTabTitle: $selectedTabTitle,
                tabState: viewModel.tabStates[currentFeedingStatus],
                hasReviewedFeedingsThisSession: viewModel.hasReviewedFeedingsThisSession,
                currentFeedingStatus: currentFeedingStatus,
                onBack: { viewModel.goBack() },
                actions: FeedingItemActions(
                    onApprove: { item in
                        Task {
                            await viewModel.approve(item)
                        }
                    },
                    onReject: { item in
                        itemPendingRejection = item
                    },
                    onTap: { item in
                        selectedItem = item
                    }
                )
            )
            .task {
                await viewModel.loadAll()
            }

            if let item = itemPendingRejection {
                rejectionPopup(for: item)
            }

            if viewModel.isProcessingAction {
                processingOverlay
            }
        }
        .animation(.easeInOut(duration: 0.2), value: itemPendingRejection != nil)
        .sheet(item: $selectedItem) { item in
            FeedingDetailSheet(
                item: item,
                onClose: {
                    selectedItem = nil
                },
                onApprove: {
                    selectedItem = nil
                    Task {
                        await viewModel.approve(item)
                    }
                },
                onRejectConfirmed: { reason in
                    selectedItem = nil
                    Task {
                        await viewModel.reject(item, reason: reason)
                    }
                }
            )
            .environmentObject(style)
            .presentationDragIndicator(.visible)
        }
        .alert(
            L10n.Errors.somethingWrong.asBaseError().description,
            isPresented: Binding(
                get: { viewModel.actionErrorMessage != nil },
                set: { if !$0 { viewModel.actionErrorMessage = nil } }
            )
        ) {
            Button(L10n.Action.ok, role: .cancel) {
                viewModel.actionErrorMessage = nil
            }
        }
    }

    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            ProgressView()
        }
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
}
