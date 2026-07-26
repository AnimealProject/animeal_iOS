import SwiftUI
import Amplify
import Style

struct FeedingsListView: View {
    // TEMP (see [[15.2-feedings-swipe]] in Tolaria): swipe is spec'd as Pending-only,
    // but is enabled for every status right now to make it easy to try on real data
    // regardless of tab. Flip to `false` (or delete this flag and the `||` below)
    // once we're done trying it out.
    private static let isSwipeEnabledForAllStatuses = true

    let items: [FeedingListItem]
    let onApprove: (FeedingListItem) -> Void
    let onReject: (FeedingListItem) -> Void

    @State private var openedItemID: String?

    var body: some View {
        List(items) { item in
            row(for: item)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

    private func row(for item: FeedingListItem) -> some View {
        SwipeableFeedingCardView(
            item: item,
            isSwipeEnabled: item.status == .pending || Self.isSwipeEnabledForAllStatuses,
            openedItemID: $openedItemID,
            onApprove: { onApprove(item) },
            onReject: { onReject(item) }
        )
    }
}

#Preview {
    func mockItem(
        status: FeedingStatus,
        createdAtOffset: TimeInterval,
        address: String,
        moderatedBy: String? = nil
    ) -> FeedingListItem {
        let feeding = Feeding(
            userId: "user-1",
            status: status,
            createdAt: Temporal.DateTime(Date().addingTimeInterval(createdAtOffset)),
            updatedAt: Temporal.DateTime(Date()),
            feedingPointDetails: FeedingPointDetails(address: address),
            feedingPointFeedingsId: "point-1",
            expireAt: 0,
            moderatedBy: moderatedBy
        )
        return FeedingListItem(
            feeding,
            userName: "Serhii Terokhyn",
            moderatorName: "Serano De Berzerak",
            imageURL: URL(string: "https://picsum.photos/200")
        )
    }

    return FeedingsListView(
        items: [
            mockItem(status: .pending, createdAtOffset: -60 * 60 * 1, address: "Kazbegi st. TDN-22"),
            mockItem(status: .pending, createdAtOffset: -60 * 60 * 3, address: "Rustaveli Ave. 12"),
            mockItem(status: .pending, createdAtOffset: -60 * 60 * 8, address: "Chavchavadze Ave. 5"),
            mockItem(status: .pending, createdAtOffset: -60 * 60 * 16, address: "Vazha-Pshavela Ave. 71"),
            mockItem(status: .approved, createdAtOffset: -3600, address: "Agmashenebeli Ave. 3", moderatedBy: "System"),
            mockItem(status: .rejected, createdAtOffset: -3600, address: "Freedom Square 1"),
            mockItem(status: .outdated, createdAtOffset: -3600, address: "Marjanishvili St. 9")
        ],
        onApprove: { _ in },
        onReject: { _ in }
    )
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}
