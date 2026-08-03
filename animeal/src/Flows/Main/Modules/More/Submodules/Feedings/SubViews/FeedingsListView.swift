import SwiftUI
import Amplify
import Style

struct FeedingItemActions {
    let onApprove: (FeedingListItem) -> Void
    let onReject: (FeedingListItem) -> Void
    let onTap: (FeedingListItem) -> Void
}

struct FeedingsListView: View {
    let items: [FeedingListItem]
    let actions: FeedingItemActions

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
            isSwipeEnabled: item.status == .pending,
            openedItemID: $openedItemID,
            onApprove: { actions.onApprove(item) },
            onReject: { actions.onReject(item) },
            onTap: { actions.onTap(item) }
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
            feedingPointImageURL: URL(string: "https://picsum.photos/201"),
            imageURLs: [URL(string: "https://picsum.photos/200")].compactMap { $0 }
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
        actions: FeedingItemActions(onApprove: { _ in }, onReject: { _ in }, onTap: { _ in })
    )
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}
