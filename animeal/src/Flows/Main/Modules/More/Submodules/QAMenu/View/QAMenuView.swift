import SwiftUI
import Style

// MARK: - QAMenuView

struct QAMenuView: View {

    // MARK: - Dependencies

    @EnvironmentObject var designEngine: StyleEngine
    @ObservedObject var model: QAMenuModel

    var interactionHandler: QAMenuViewInteraction?

    @State private var pendingEnvironment: BackendEnvironment?

    // MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            headerText
            backendText
            backendEnvironmentPicker
            loadAllFeedingPointsToggle
            Spacer()
        }
        .padding([.leading, .trailing], 16)
        .padding(.top, 12)
    }

    // MARK: - Private view elements

    private var headerText: some View {
        Text(L10n.QaMenu.title)
            .font(designEngine.fonts.primary.bold(28).font)
            .foregroundColor(designEngine.colors.textPrimary.color)
    }

    private var backendText: some View {
        Text(model.backendSummary)
            .font(designEngine.fonts.primary.regular(14).font)
            .foregroundColor(designEngine.colors.textSecondary.color)
    }

    @ViewBuilder private var backendEnvironmentPicker: some View {
        if !model.backendEnvironments.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Picker(
                    QAMenuStrings.environmentPicker,
                    selection: Binding(
                        get: { model.backendEnvironment },
                        set: { pendingEnvironment = $0 }
                    )
                ) {
                    ForEach(model.backendEnvironments, id: \.self) { environment in
                        Text(environment.rawValue).tag(Optional(environment))
                    }
                }
                .pickerStyle(.segmented)
                Text(QAMenuStrings.switchWarning)
                    .font(designEngine.fonts.primary.regular(12).font)
                    .foregroundColor(designEngine.colors.textSecondary.color)
            }
            .confirmationDialog(
                QAMenuStrings.switchConfirmation(pendingEnvironment),
                isPresented: Binding(
                    get: { pendingEnvironment != nil },
                    set: { if !$0 { pendingEnvironment = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(QAMenuStrings.switchAction, role: .destructive) {
                    if let environment = pendingEnvironment {
                        interactionHandler?.handleActionEvent(.selectBackendEnvironment(environment))
                    }
                    pendingEnvironment = nil
                }
                Button(QAMenuStrings.cancel, role: .cancel) { pendingEnvironment = nil }
            }
        }
    }

    private var loadAllFeedingPointsToggle: some View {
        Toggle(
            L10n.QaMenu.loadAllFeedingPoints,
            isOn: Binding(
                get: { model.isLoadAllFeedingPointsEnabled },
                set: { interactionHandler?.handleActionEvent(.toggleLoadAllFeedingPoints($0)) }
            )
        )
        .font(designEngine.fonts.primary.regular(14).font)
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
