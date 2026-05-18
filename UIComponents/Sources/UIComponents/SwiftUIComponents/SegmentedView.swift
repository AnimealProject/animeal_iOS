//
//  SegmentedView.swift
//  UIComponents
//
//  Created by Luka Alimbarashvili on 07.05.26.
//

import SwiftUI
import Style

private enum Constants {
    static let containerPadding: CGFloat = 3
    static let cornerRadius: CGFloat = 10
    static let shadowColor = Color.black.opacity(0.12)
}

public struct SegmentedView: View {
    private let designEngine: StyleEngine = StyleDefaultEngine()
    private let items: [String]
    @Binding private var selection: String
    @Namespace private var selectionAnimation

    public init(items: [String], selection: Binding<String>) {
        self.items = items
        _selection = selection
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                tabButton(for: item)
            }
        }
        .padding(Constants.containerPadding)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: Constants.cornerRadius + Constants.containerPadding)
        )
        .shadow(color: Constants.shadowColor, radius: 24, x: 0, y: 12)
    }

    private func tabButton(for item: String) -> some View {
        let isSelected = selection == item

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = item
            }
        } label: {
            Text(item)
                .font(tabFont)
                .foregroundColor(isSelected ? .white : .black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 32)
                .background(tabBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }

    private var tabFont: Font {
        designEngine.fonts.primary.medium(14)?.font ?? .system(size: 14, weight: .medium)
    }

    private func tabBackground(isSelected: Bool) -> some View {
        ZStack {
            if isSelected {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(designEngine.colors.accent.color)
                    .matchedGeometryEffect(id: "selected_segment", in: selectionAnimation)
            }
        }
    }
}
