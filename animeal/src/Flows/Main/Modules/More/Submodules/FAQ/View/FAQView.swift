import Style
import SwiftUI

struct FAQView<ViewModel: FAQViewModelProtocol>: View {
    
    // MARK: - UI Constants

    private enum Constants {
        static var padding: EdgeInsets { .init(top: 12, leading: 26, bottom: 8, trailing: 26) }
        static var headerBottomPadding: CGFloat { 32 }
        static var headerBodyTopPadding: CGFloat { 10 }
    }

    // MARK: - Dependencies

    @EnvironmentObject var designEngine: StyleEngine
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    headerText
                        .padding(.bottom, Constants.headerBottomPadding)
                    faqContent
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
            Text(L10n.Faq.title)
                .font(designEngine.fonts.primary.bold(28)?.font)
            Text(L10n.Faq.Header.text)
                .font(designEngine.fonts.primary.regular(16)?.font)
                .padding(.top, Constants.headerBodyTopPadding)
        }
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(designEngine.colors.textPrimary.color)
    }
    
    private var faqContent: some View {
        ForEach($viewModel.faqItems) { item in
            QuestionRow(
                item: item,
                toggle: {
                    self.viewModel.handleActionEvent(
                        .toggleItem(item.id)
                    )
                }
            )
            .frame(maxWidth: .infinity)
        }
    }
    
    private var footerText: some View {
        Text(viewModel.footerText)
            .textSelection(.enabled)
            .font(designEngine.fonts.primary.regular(16)?.font)
            .foregroundColor(designEngine.colors.textPrimary.color)
            .accentColor(designEngine.colors.textPrimary.color)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

extension FAQView {
    struct QuestionRow: View {
        private enum Constants {
            static var padding: EdgeInsets {
                .init(top: 10, leading: 8, bottom: 10, trailing: 8)
            }
            
            static var contentPadding: EdgeInsets {
                .init(top: 15, leading: 21, bottom: 15, trailing: 14)
            }
        }
        
        @EnvironmentObject var designEngine: StyleEngine
        @Binding var item: FAQViewItem
        var showAnswer: Bool { !item.collapsed }
        let toggle: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                Button(
                    action: { withAnimation { toggle() } },
                    label: {
                        HStack {
                            Text(item.question)
                                .font(designEngine.fonts.primary.regular(16)?.font)
                                .frame(maxHeight: .infinity)
                            Spacer()
                            Image(asset: item.collapsed ? Asset.Images.arrowDown : Asset.Images.arrowUp)
                                .renderingMode(.template)
                        }
                        .foregroundColor(designEngine.colors.textPrimary.color)
                        .padding(Constants.padding)
                        .contentShape(Rectangle())
                    }
                )
                .buttonStyle(PlainButtonStyle())
                .fixedSize(horizontal: false, vertical: true)
                
                if showAnswer {
                    VStack {
                        HStack {
                            Text(item.answer)
                                .font(designEngine.fonts.primary.regular(14)?.font)
                                .foregroundColor(designEngine.colors.textPrimary.color)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Constants.contentPadding)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(designEngine.colors.backgroundSecondary.color, lineWidth: 1)
                        )
                    }
                    .padding(Constants.padding)
                    .clipped()
                }
                
            }
        }
    }
}
