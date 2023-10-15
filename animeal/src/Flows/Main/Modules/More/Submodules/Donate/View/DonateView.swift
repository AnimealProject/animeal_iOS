import Style
import SwiftUI
import Kingfisher

struct DonateView<ViewModel: DonateViewModelProtocol>: View {

    // MARK: - UI Constants

    private enum Constants {
        static var padding: EdgeInsets { .init(top: 12, leading: 26, bottom: 8, trailing: 26) }
        static var spacing: CGFloat { 32 }
        static var headerBodyTopPadding: CGFloat { 10 }
    }

    // MARK: - Dependencies

    @EnvironmentObject var designEngine: StyleEngine
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: Constants.spacing) {
                    headerText
                    picture
                        .frame(maxWidth: geometry.size.width * 0.82)
                        .padding(.horizontal, 12)

                    paymentMethodsContent
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    footerText
                }
                .padding(Constants.padding)
                .frame(minHeight: geometry.size.height)
            }
        }
    }

    // MARK: - Private view elements

    private var headerText: some View {
        VStack(alignment: .leading) {
            Text(L10n.Donate.title)
                .font(designEngine.fonts.primary.bold(28)?.font)
            Text(L10n.Donate.Header.text)
                .font(designEngine.fonts.primary.regular(16)?.font)
                .padding(.top, Constants.headerBodyTopPadding)
        }
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(designEngine.colors.textPrimary.color)
    }

    private var picture: some View {
        Image(asset: Asset.Images.donatePhoto)
            .aspectRatio(1 / 2, contentMode: .fill)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(designEngine.colors.backgroundSecondary.color, lineWidth: .pixel)
            )
    }

    private var paymentMethodsContent: some View {
        ForEach($viewModel.paymentMethodsItems) { item in
            PaymentMethodRow(
                item: item,
                copyTapped: {
                    self.viewModel.handleActionEvent(
                        .tapOnCopyPaymentMethod(id: item.id)
                    )
                }
            )
            .frame(maxWidth: .infinity)
        }
    }

    private var footerText: some View {
        Text(L10n.Donate.Footer.text)
            .font(designEngine.fonts.primary.regular(16)?.font)
            .foregroundColor(designEngine.colors.textPrimary.color)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

extension DonateView {
    struct PaymentMethodRow: View {
        @EnvironmentObject var designEngine: StyleEngine
        @Binding var item: PaymentMethodViewItem
        let copyTapped: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(item.name)
                    .font(designEngine.fonts.primary.bold(14)?.font)
                    .foregroundColor(designEngine.colors.textPrimary.color)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 14 * 1.5)
                    .padding(.bottom, 2)

                HStack(alignment: .center, spacing: 0) {
                    icon
                        .padding(.vertical, 15)
                        .padding(.leading, 18)
                        .padding(.trailing, 16)

                    Text(item.details)
                        .font(designEngine.fonts.primary.light(16)?.font)
                        .foregroundColor(designEngine.colors.textPrimary.color)
                        .lineLimit(1)

                    Spacer()
                    Button(action: copyTapped) {
                        Image(asset: Asset.Images.copy)
                            .renderingMode(.template)
                            .foregroundColor(designEngine.colors.textPrimary.color)
                            .padding(.trailing, 18)
                            .padding(.vertical, 14)
                    }
                }
                .background(
                    designEngine.colors.backgroundSecondary.color
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                )
            }
        }

        var icon: some View {
            KFImage(item.iconURL)
                .loadDiskFileSynchronously()
                .cacheOriginalImage()
                .fade(duration: 0.25)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)
        }
    }
}
