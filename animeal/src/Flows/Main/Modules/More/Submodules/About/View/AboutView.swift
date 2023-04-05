//
//  AboutView.swift
//  animeal
//
//  Created by Mikhail Churbanov on 1/26/23.
//

import SwiftUI
import Style

// MARK: - AboutView

struct AboutView: View {

    // MARK: - UI Constants

    private enum Constants {
        static let topPadding: CGFloat = 12
        static let verticalSpacing: CGFloat = 32
        static let horizontalPadding: CGFloat = 32
        static let socialMediaIconSize: CGFloat = 62
        static let photoCornerRadius: CGFloat = 12
    }

    // MARK: - Dependencies

    @EnvironmentObject var designEngine: StyleEngine
    @ObservedObject var model: AboutModel

    var interactionHandler: AboutViewInteraction?

    // MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    VStack() {
                        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                            headerText
                            photoImage
                            contentText
                        }
                        Spacer(minLength: Constants.verticalSpacing)
                        appVersionText
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            linkButtonsView
        }
        .padding([.leading, .trailing], Constants.horizontalPadding / 2)
        .padding(.top, Constants.topPadding)
    }

    // MARK: - Private view elements

    private var headerText: some View {
        Text(L10n.More.aboutShort)
            .font(designEngine.fonts.primary.bold(28)?.font)
            .foregroundColor(designEngine.colors.textPrimary.color)
    }

    private var photoImage: some View {
        Asset.Images.aboutPhoto.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(Constants.photoCornerRadius)
    }

    private var contentText: some View {
        Text(model.contentText)
            .font(designEngine.fonts.primary.regular(14)?.font)
            .foregroundColor(designEngine.colors.textPrimary.color)
    }

    private var appVersionText: some View {
        Text(model.appVersion)
            .font(designEngine.fonts.primary.regular(14)?.font)
            .foregroundColor(designEngine.colors.textSecondary.color)
    }

    private func linkButton(_ link: AboutLink) -> some View {
        Button(
            action: {
                interactionHandler?.handleActionEvent(.linkTapped(link))
            },
            label: {
                link.image
                    .resizable()
                    .frame(width:  Constants.socialMediaIconSize, height:  Constants.socialMediaIconSize)
            }
        )
        .disabled(link.disabled)
        .opacity(link.disabled ? 0.33 : 1)
    }

    private var linkButtonsView: some View {
        HStack(alignment: .center) {
            Spacer()
            ForEach(model.links, content: linkButton)
            Spacer()
        }
    }
}

// MARK: - Preview

struct AboutView_Previews: PreviewProvider {
    static let designEngine: StyleEngine = StyleDefaultEngine()
    static let model: AboutModel = AboutModel.previewModel

    static var previews: some View {
        AboutView(model: model)
            .environmentObject(designEngine)
    }
}
