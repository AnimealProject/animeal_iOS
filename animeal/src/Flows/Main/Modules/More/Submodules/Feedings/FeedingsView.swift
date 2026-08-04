import SwiftUI
import UIComponents
import Style

enum FeedingsTab: CaseIterable {
    case pending
    case approved
    case rejected
    case outdated

    var status: FeedingStatus {
        switch self {
        case .pending: return .pending
        case .approved: return .approved
        case .rejected: return .rejected
        case .outdated: return .outdated
        }
    }

    var title: String {
        switch self {
        case .pending: return L10n.Feedings.pending
        case .approved: return L10n.Feedings.approved
        case .rejected: return L10n.Feedings.rejected
        case .outdated: return L10n.Feedings.outdated
        }
    }
}

struct FeedingsView: View {
    var viewModel: FeedingsViewModel

    @EnvironmentObject private var style: StyleEngine

    @State private var selectedTab: FeedingsTab = .pending
    @State private var itemPendingRejection: FeedingListItem?
    @State private var selectedItem: FeedingListItem?

    private var currentFeedingStatus: FeedingStatus {
        selectedTab.status
    }

    var body: some View {
        ZStack {
            FeedingsScreenContent(
                selectedTab: $selectedTab,
                tabState: viewModel.tabStates[currentFeedingStatus],
                hasReviewedFeedingsThisSession: viewModel.hasReviewedFeedingsThisSession,
                currentFeedingStatus: currentFeedingStatus,
                onBack: { viewModel.goBack() },
                onRetry: {
                    Task {
                        await viewModel.load(status: currentFeedingStatus)
                    }
                },
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
            ),
            presenting: viewModel.actionErrorMessage
        ) { _ in
            Button(L10n.Action.ok, role: .cancel) {
                viewModel.actionErrorMessage = nil
            }
        } message: { message in
            Text(message)
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
