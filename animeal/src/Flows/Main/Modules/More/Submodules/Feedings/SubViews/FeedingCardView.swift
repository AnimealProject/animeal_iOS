import SwiftUI
import Kingfisher
import Amplify
import Style

struct FeedingCardView: View {
    @EnvironmentObject private var style: StyleEngine

    var item: FeedingListItem

    var body: some View {
        HStack {
            KFImage(item.feedingPointImageURL)
                .loadDiskFileSynchronously()
                .cacheOriginalImage()
                .fade(duration: 0.3)
                .placeholder { FeedingImagePlaceholder() }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 81, height: 81)
                .cornerRadius(16)
                .padding(12)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.address)
                        .font(style.fonts.secondary.medium(16).font)
                        .lineLimit(1)
                    Spacer()
                    Text(Self.relativeDateFormatter.localizedString(for: item.date, relativeTo: NetTime.now))
                        .font(style.fonts.secondary.light(12).font)
                        .layoutPriority(1)
                        .padding(.horizontal, 4)
                }
                Text(item.user.userName ?? "")
                    .font(style.fonts.secondary.regular(14).font)
                FeedingStatusBadge(
                    status: FeedingStatusBadge.Status(
                        status: item.status,
                        review: item.review,
                        date: item.date
                    )
                )
            }
            Spacer(minLength: 0)
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Asset.Colors.backgroundPrimary.swiftUIColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Asset.Colors.geyser.swiftUIColor, lineWidth: 1)
        )
    }

    /// Produces relative strings like: "34 minutes ago", "2 hours ago".
    /// Shared with FeedingDetailSheet's header.
    static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        return formatter
    }()
}

#Preview {
    func mockItem(
        status: FeedingStatus,
        createdAtOffset: TimeInterval,
        address: String = "Kazbegi st. TDN-22",
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

    return ScrollView {
        VStack(spacing: 8) {
            FeedingCardView(
                item: mockItem(
                    status: .approved,
                    createdAtOffset: -3600,
                    address: "Tbilisi Zoo, კოსტავას ქუჩა, თბილისი, საქართველო",
                    moderatedBy: "System"
                )
            )
            FeedingCardView(item: mockItem(status: .approved, createdAtOffset: -3600, moderatedBy: "moderator-1"))
            FeedingCardView(item: mockItem(status: .pending, createdAtOffset: -60 * 60 * 1))
            FeedingCardView(item: mockItem(status: .pending, createdAtOffset: -60 * 60 * 3))
            FeedingCardView(item: mockItem(status: .pending, createdAtOffset: -60 * 60 * 8))
            FeedingCardView(item: mockItem(status: .pending, createdAtOffset: -60 * 60 * 16))
            FeedingCardView(item: mockItem(status: .rejected, createdAtOffset: -3600))
            FeedingCardView(item: mockItem(status: .outdated, createdAtOffset: -3600))
        }
        .padding(16)
    }
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}
