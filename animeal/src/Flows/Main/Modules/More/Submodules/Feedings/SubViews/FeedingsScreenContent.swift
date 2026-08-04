import SwiftUI
import UIComponents
import Style

struct FeedingsScreenContent: View {
    @Binding var selectedTab: FeedingsTab
    let tabState: FeedingTabState?
    let hasReviewedFeedingsThisSession: Bool
    let currentFeedingStatus: FeedingStatus
    let onBack: () -> Void
    let actions: FeedingItemActions

    @EnvironmentObject private var style: StyleEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            backButton
            titleText

            SegmentedView(
                items: FeedingsTab.allCases,
                selection: $selectedTab,
                title: \.title
            )

            content

            Spacer()
        }
        .padding()
    }

    private var backButton: some View {
        Button(action: onBack) {
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
        switch tabState {
        case .none, .failed:
            Text(L10n.Errors.somethingWrong.asBaseError().description)
                .foregroundColor(style.colors.error.color)
        case .isLoading:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .loaded(let items):
            if items.isEmpty {
                emptyState
            } else {
                FeedingsListView(items: items, actions: actions)
            }
        }
    }

    @ViewBuilder private var emptyState: some View {
        let isWellDone = currentFeedingStatus == .pending && hasReviewedFeedingsThisSession
        EmptyStateView(
            image: Asset.Images.emptyStateBone,
            title: isWellDone ? L10n.Feedings.Empty.wellDoneTitle : L10n.Feedings.Empty.oopsTitle,
            subtitle: isWellDone ? L10n.Feedings.Empty.wellDoneSubtitle : L10n.Feedings.Empty.oopsSubtitle,
            titleColor: style.colors.accent.color,
            subtitleColor: style.colors.textPrimary.color
        )
        .padding(.top, 48)
    }
}

#Preview("Well done") {
    FeedingsScreenContent(
        selectedTab: .constant(.pending),
        tabState: .loaded([]),
        hasReviewedFeedingsThisSession: true,
        currentFeedingStatus: .pending,
        onBack: { },
        actions: FeedingItemActions(onApprove: { _ in }, onReject: { _ in }, onTap: { _ in })
    )
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}

#Preview("Ooops - empty Pending") {
    FeedingsScreenContent(
        selectedTab: .constant(.pending),
        tabState: .loaded([]),
        hasReviewedFeedingsThisSession: false,
        currentFeedingStatus: .pending,
        onBack: { },
        actions: FeedingItemActions(onApprove: { _ in }, onReject: { _ in }, onTap: { _ in })
    )
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}

#Preview("Ooops - empty Approved") {
    FeedingsScreenContent(
        selectedTab: .constant(.approved),
        tabState: .loaded([]),
        hasReviewedFeedingsThisSession: true,
        currentFeedingStatus: .approved,
        onBack: { },
        actions: FeedingItemActions(onApprove: { _ in }, onReject: { _ in }, onTap: { _ in })
    )
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}

#Preview("Loading") {
    FeedingsScreenContent(
        selectedTab: .constant(.pending),
        tabState: .isLoading,
        hasReviewedFeedingsThisSession: false,
        currentFeedingStatus: .pending,
        onBack: { },
        actions: FeedingItemActions(onApprove: { _ in }, onReject: { _ in }, onTap: { _ in })
    )
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}
