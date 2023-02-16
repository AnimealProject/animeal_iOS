//
//  AnimealButton.swift
//  
//
//  Created by Mikhail Churbanov on 2/16/23.
//

import SwiftUI
import Style

public struct AnimealButton: View {

    @EnvironmentObject var designEngine: StyleEngine

    public let action: () -> Void
    public let title: String

    public init(action: @escaping () -> Void, title: String) {
        self.action = action
        self.title = title
    }

    public var body: some View {
        Button(action: action, label: {
            HStack {
                Spacer()
                Text(title)
                    .foregroundColor(.white)
                    .font(designEngine.fonts.primary.bold(16)?.font)
                Spacer()
            }
            .frame(height: 60)
        })
        .background(Asset.Colors.darkTurquoise.swiftUIColor)
        .cornerRadius(30)
    }
}

// MARK: - Preview

struct AnimealButton_Previews: PreviewProvider {
    static var previews: some View {
        AnimealButton(action: {}, title: "Push Me")
    }
}
