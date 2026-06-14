import SwiftUI
import Style

// MARK: - QAMenuView

struct QAMenuView: View {

    // MARK: - Dependencies

    @EnvironmentObject var designEngine: StyleEngine
    @ObservedObject var model: QAMenuModel

    var interactionHandler: QAMenuViewInteraction?

    // MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            headerText
            loadAllFeedingPointsToggle
            Spacer()
        }
        .padding([.leading, .trailing], 16)
        .padding(.top, 12)
    }

    // MARK: - Private view elements

    private var headerText: some View {
        Text(L10n.QaMenu.title)
            .font(designEngine.fonts.primary.bold(28)?.font)
            .foregroundColor(designEngine.colors.textPrimary.color)
    }

    private var loadAllFeedingPointsToggle: some View {
        Toggle(
            L10n.QaMenu.loadAllFeedingPoints,
            isOn: Binding(
                get: { model.isLoadAllFeedingPointsEnabled },
                set: { interactionHandler?.handleActionEvent(.toggleLoadAllFeedingPoints($0)) }
            )
        )
        .font(designEngine.fonts.primary.regular(14)?.font)
        .foregroundColor(designEngine.colors.textPrimary.color)
    }
}

// MARK: - Preview

struct QAMenuView_Previews: PreviewProvider {
    static let designEngine: StyleEngine = StyleDefaultEngine()
    static let model = QAMenuModel()

    static var previews: some View {
        QAMenuView(model: model)
            .environmentObject(designEngine)
    }
}
