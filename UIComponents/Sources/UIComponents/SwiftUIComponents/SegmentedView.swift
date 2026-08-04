import SwiftUI
import Style

private enum Constants {
    static let containerPadding: CGFloat = 3
    static let cornerRadius: CGFloat = 10
    static let shadowColor = Color.black.opacity(0.12)
    static let shadowRadius: CGFloat = 6
    static let shadowOffsetX: CGFloat = 2
    static let shadowOffsetY: CGFloat = 4
}

public struct SegmentedView<Item: Hashable>: View {
    @EnvironmentObject private var designEngine: StyleEngine
    private let items: [Item]
    @Binding private var selection: Item
    private let title: (Item) -> String
    @Namespace private var selectionAnimation

    public init(items: [Item], selection: Binding<Item>, title: @escaping (Item) -> String) {
        self.items = items
        _selection = selection
        self.title = title
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                tabButton(for: item)
            }
        }
        .padding(Constants.containerPadding)
        .background(designEngine.colors.backgroundPrimary.color)
        .clipShape(
            RoundedRectangle(cornerRadius: Constants.cornerRadius + Constants.containerPadding)
        )
        .shadow(
            color: Constants.shadowColor,
            radius: Constants.shadowRadius,
            x: Constants.shadowOffsetX,
            y: Constants.shadowOffsetY
        )
    }

    private func tabButton(for item: Item) -> some View {
        let isSelected = selection == item

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = item
            }
        } label: {
            Text(title(item))
                .font(tabFont)
                .foregroundColor(
                    isSelected ? designEngine.colors.alwaysLight.color : designEngine.colors.textPrimary.color
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 32)
                .background(tabBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }

    private var tabFont: Font {
        designEngine.fonts.primary.medium(14).font
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
