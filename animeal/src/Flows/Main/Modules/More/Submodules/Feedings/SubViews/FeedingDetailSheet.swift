import SwiftUI
import Kingfisher
import Amplify
import Style

struct FeedingDetailSheet: View {
    private enum Constants {
        static let headerImageSize: CGFloat = 81
        static let thumbnailSize: CGFloat = 56
        static let cornerRadius: CGFloat = 16
    }

    @EnvironmentObject private var style: StyleEngine

    let item: FeedingListItem
    let onClose: () -> Void
    let onApprove: () -> Void
    let onRejectConfirmed: (String) -> Void

    @State private var selectedImageIndex = 0
    @State private var isRejectionReasonPresented = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                header
                mainPhoto
                thumbnailCarousel
                reviewDetails
                Spacer(minLength: 0)
                actionButtons
            }
            .padding(24)

            if isRejectionReasonPresented {
                rejectionPopup
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isRejectionReasonPresented)
    }
}

private extension FeedingDetailSheet {
    var header: some View {
        HStack(alignment: .top, spacing: 12) {
            KFImage(item.feedingPointImageURL)
                .loadDiskFileSynchronously()
                .cacheOriginalImage()
                .fade(duration: 0.3)
                .placeholder { FeedingImagePlaceholder() }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Constants.headerImageSize, height: Constants.headerImageSize)
                .cornerRadius(Constants.cornerRadius)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.address)
                        .font(style.fonts.secondary.medium(16).font)
                        .lineLimit(1)
                    Spacer()
                    Text(
                        FeedingCardView.relativeDateFormatter.localizedString(
                            for: item.date,
                            relativeTo: NetTime.now
                        )
                    )
                    .font(style.fonts.secondary.light(12).font)
                    .layoutPriority(1)
                }
                Text(L10n.Feeding.feededBy(item.user.userName ?? ""))
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

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(style.colors.textSecondary.color)
            }
        }
    }

    var mainPhoto: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 380)
            .overlay {
                KFImage(selectedImageURL)
                    .loadDiskFileSynchronously()
                    .cacheOriginalImage()
                    .fade(duration: 0.3)
                    .placeholder { FeedingImagePlaceholder() }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }

    var selectedImageURL: URL? {
        guard item.imageURLs.indices.contains(selectedImageIndex) else { return item.imageURLs.first }
        return item.imageURLs[selectedImageIndex]
    }

    @ViewBuilder var thumbnailCarousel: some View {
        if item.imageURLs.count > 1 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(item.imageURLs.enumerated()), id: \.offset) { index, url in
                        thumbnail(url: url, isSelected: index == selectedImageIndex)
                            .onTapGesture { selectedImageIndex = index }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: Constants.thumbnailSize)
            .clipped()
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
    }

    func thumbnail(url: URL, isSelected: Bool) -> some View {
        KFImage(url)
            .loadDiskFileSynchronously()
            .cacheOriginalImage()
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: Constants.thumbnailSize, height: Constants.thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isSelected ? style.colors.accent.color : .clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected ? style.colors.accent.color.opacity(0.6) : .clear,
                radius: 4
            )
    }

    @ViewBuilder var reviewDetails: some View {
        VStack(alignment: .leading, spacing: 0) {
            if case .reviewedBy(let moderator) = item.review {
                Text(L10n.Feeding.reviewedBy(moderator.userName ?? moderator.userId))
                    .font(style.fonts.secondary.regular(14).font)
                    .foregroundColor(style.colors.textPrimary.color)
                    .lineSpacing(6)
            }
            if item.status == .rejected, let reason = item.rejectionReason {
                Text(L10n.Feeding.rejectionReason(reason))
                    .font(style.fonts.secondary.regular(14).font)
                    .foregroundColor(style.colors.textPrimary.color)
                    .lineSpacing(6)
            }
        }
    }

    var actionButtons: some View {
        HStack(alignment: .center, spacing: 12) {
            FeedingCapsuleButtonFactory.outlined(
                title: L10n.Feeding.reject,
                style: style,
                isEnabled: item.status == .pending
            ) {
                isRejectionReasonPresented = true
            }

            FeedingCapsuleButtonFactory.filled(
                title: L10n.Feeding.approve,
                style: style,
                isEnabled: item.status == .pending
            ) {
                onApprove()
            }
        }
    }

    var rejectionPopup: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isRejectionReasonPresented = false
                }

            FeedingRejectionReasonAlert(
                onCancel: {
                    isRejectionReasonPresented = false
                },
                onReject: { reason in
                    isRejectionReasonPresented = false
                    onRejectConfirmed(reason)
                }
            )
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Asset.Colors.backgroundPrimary.swiftUIColor)
            )
            .padding(.horizontal, 24)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

#Preview {
    let feeding = Feeding(
        userId: "user-1",
        status: .pending,
        createdAt: Temporal.DateTime(Date().addingTimeInterval(-3600)),
        updatedAt: Temporal.DateTime(Date()),
        feedingPointDetails: FeedingPointDetails(address: "Kazbegi st. TDN-22"),
        feedingPointFeedingsId: "point-1",
        expireAt: 0,
        moderatedBy: nil
    )
    let item = FeedingListItem(
        feeding,
        userName: "Giorgi Abutibze",
        moderatorName: nil,
        feedingPointImageURL: URL(string: "https://picsum.photos/seed/point/200"),
        imageURLs: [
            URL(string: "https://picsum.photos/seed/1/400"),
            URL(string: "https://picsum.photos/seed/2/400"),
            URL(string: "https://picsum.photos/seed/3/400")
        ].compactMap { $0 }
    )

    FeedingDetailSheet(
        item: item,
        onClose: { },
        onApprove: { },
        onRejectConfirmed: { _ in }
    )
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}
