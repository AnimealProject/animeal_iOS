import SwiftUI
import Amplify
import Style

struct FeedingsListView: View {
    let items: [FeedingListItem]

    var body: some View {
        List(items) { item in
            FeedingCardView(item: item)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
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
        ]
    )
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}
