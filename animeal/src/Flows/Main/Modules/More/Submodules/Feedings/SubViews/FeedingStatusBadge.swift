import SwiftUI
import Style

struct FeedingStatusBadge: View {
    enum Status {
        case autoApproved
        case approved
        case pending(Int)
        case rejected
        case outdated

        var color: Color {
            switch self {
            case .autoApproved:
                return Asset.Colors.FeedingStatus.green.swiftUIColor
            case .approved:
                return Asset.Colors.FeedingStatus.green.swiftUIColor
            case .pending(let age):
                switch age {
                case 0..<(2 * 60 * 60):
                    return Asset.Colors.FeedingStatus.grey.swiftUIColor
                case (2 * 60 * 60)..<(6 * 60 * 60):
                    return Asset.Colors.FeedingStatus.yellow.swiftUIColor
                case (6 * 60 * 60)...(12 * 60 * 60):
                    return Asset.Colors.FeedingStatus.red.swiftUIColor
                default:
                    return Asset.Colors.FeedingStatus.maroon.swiftUIColor
                }
            case .rejected:
                return Asset.Colors.FeedingStatus.red.swiftUIColor
            case .outdated:
                return Asset.Colors.FeedingStatus.maroon.swiftUIColor
            }
        }

        var text: String {
            switch self {
            case .autoApproved, .approved:
                return L10n.Feedings.approved
            case .pending:
                return L10n.Feedings.pending
            case .rejected:
                return L10n.Feedings.rejected
            case .outdated:
                return L10n.Feedings.outdated
            }
        }

        init(status: FeedingStatus, review: FeedingReview, date: Date) {
            switch status {
            case .approved:
                if case .autoApproved = review {
                    self = .autoApproved
                } else {
                    self = .approved
                }
            case .rejected:
                self = .rejected
            case .pending, .inProgress:
                self = .pending(Int(Date().timeIntervalSince(date)))
            case .outdated:
                self = .outdated
            }
        }
    }

    @EnvironmentObject var style: StyleEngine
    @State var status: Status

    var body: some View {
        HStack {
            Image(systemName: "ellipsis.circle")
                .font(style.fonts.secondary.regular(12).font)
                .foregroundColor(status.color)
            Text(status.text)
                .font(style.fonts.secondary.regular(12).font)
                .foregroundColor(status.color)
        }
    }
}

#Preview {
    VStack {
        FeedingStatusBadge(status: .approved)
            .environmentObject(StyleDefaultEngine() as StyleEngine)
        FeedingStatusBadge(status: .autoApproved)
            .environmentObject(StyleDefaultEngine() as StyleEngine)
        FeedingStatusBadge(status: .pending(60 * 60 * 1))
            .environmentObject(StyleDefaultEngine() as StyleEngine)
        FeedingStatusBadge(status: .pending(60 * 60 * 3))
            .environmentObject(StyleDefaultEngine() as StyleEngine)
        FeedingStatusBadge(status: .pending(60 * 60 * 8))
            .environmentObject(StyleDefaultEngine() as StyleEngine)
        FeedingStatusBadge(status: .pending(60 * 60 * 16))
            .environmentObject(StyleDefaultEngine() as StyleEngine)
        FeedingStatusBadge(status: .rejected)
            .environmentObject(StyleDefaultEngine() as StyleEngine)
        FeedingStatusBadge(status: .outdated)
            .environmentObject(StyleDefaultEngine() as StyleEngine)
    }
}
