//
//  FeedingFinishedView.swift
//  animeal
//
//  Created by Mikhail Churbanov on 2/5/23.
//

import SwiftUI
import Style
import UIComponents

struct FeedingFinishedView: View {

    // MARK: - Dependencies

    @EnvironmentObject var designEngine: StyleEngine
    @ObservedObject var model: FeedingFinishedModel

    var interactionHandler: FeedingFinishedViewInteraction?

    // MARK: - body

    var body: some View {
        VStack {
            thankYouGroup
            backButton
        }
        .padding(24)
        .background(Asset.Colors.backgroundPrimary.swiftUIColor)
    }

    private var thankYouGroup: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            Asset.Images.feedingThankYou.swiftUIImage
            Text(L10n.Text.thankYou)
                .foregroundColor(Asset.Colors.darkTurquoise.swiftUIColor)
                .font(designEngine.fonts.primary.bold(32)?.font)
            Text(L10n.Text.animalsAreFed)
                .foregroundColor(designEngine.colors.textPrimary.color)
                .font(designEngine.fonts.primary.regular(16)?.font)
            Spacer()
        }
    }

    private var backButton: some View {
        AnimealButton(action: {
            interactionHandler?.handleActionEvent(.backToHome)
        }, title: L10n.Action.backToHome)
    }
}

struct FeedingFinishedView_Previews: PreviewProvider {
    static let designEngine: StyleEngine = StyleDefaultEngine()
    static let model: FeedingFinishedModel = FeedingFinishedModel.previewModel

    static var previews: some View {
        FeedingFinishedView(model: model)
            .environmentObject(designEngine)
    }
}
