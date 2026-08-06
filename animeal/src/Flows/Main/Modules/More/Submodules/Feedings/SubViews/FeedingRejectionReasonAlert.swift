import SwiftUI
import Style
import UIComponents

struct FeedingRejectionReasonAlert: View {
    enum Reason: Equatable {
        case noFood
        case badPhotoQuality
        case feedingPointNotVisible
        case inappropriateContent
        case other
    }

    @EnvironmentObject var style: StyleEngine

    @State var reason: Reason = .noFood
    @State var otherReason: String?

    let onCancel: () -> Void
    let onReject: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Feeding.Reason.title)
                .font(style.fonts.secondary.bold(18).font)
            createCheckbox(checkboxText: L10n.Feeding.Reason.noFood, reason: .noFood)
            createCheckbox(checkboxText: L10n.Feeding.Reason.badPhotoQuality, reason: .badPhotoQuality)
            createCheckbox(checkboxText: L10n.Feeding.Reason.feedingPointNotVisible, reason: .feedingPointNotVisible)
            createCheckbox(checkboxText: L10n.Feeding.Reason.inappropriateContent, reason: .inappropriateContent)
            createCheckbox(checkboxText: L10n.Feeding.Reason.other, reason: .other)
            if reason == .other {
                VStack(alignment: .leading, spacing: 4) {
                    TextEditor(
                        text: Binding(
                            get: { otherReason ?? "" },
                            set: { otherReason = $0 }
                        )
                    )
                    .frame(height: 100)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                Asset.Colors.carminePink.swiftUIColor,
                                lineWidth: 1
                            )
                    }
                    Text(L10n.Feeding.Reason.Other.explanation)
                        .font(style.fonts.secondary.regular(10).font)
                        .foregroundColor(Asset.Colors.carminePink.swiftUIColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                }
            }
            HStack(alignment: .center, spacing: 12) {
                FeedingCapsuleButtonFactory.outlined(title: L10n.Feeding.Reason.cancel, style: style) {
                    onCancel()
                }

                FeedingCapsuleButtonFactory.filled(
                    title: L10n.Feeding.reject,
                    style: style,
                    isEnabled: isRejectEnabled
                ) {
                    onReject(resolvedReasonText)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: reason == .other)
    }

    private var isRejectEnabled: Bool {
        reason != .other || !trimmedOtherReason.isEmpty
    }

    private var trimmedOtherReason: String {
        (otherReason ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var resolvedReasonText: String {
        switch reason {
        case .noFood: L10n.Feeding.Reason.noFood
        case .badPhotoQuality: L10n.Feeding.Reason.badPhotoQuality
        case .feedingPointNotVisible: L10n.Feeding.Reason.feedingPointNotVisible
        case .inappropriateContent: L10n.Feeding.Reason.inappropriateContent
        case .other: trimmedOtherReason
        }
    }

    func createCheckbox(checkboxText: String, reason: Reason) -> CheckboxRadioButton {
        CheckboxRadioButton(
            checkboxSelectedAsset: Asset.Images.checkboxRadioSelected,
            checkboxUnselectedAsset: Asset.Images.checkboxRadioUnselected,
            checkboxText: checkboxText,
            isSelected: Binding(
                get: {
                    self.reason == reason
                },
                set: { isOn in
                    if isOn {
                        self.reason = reason
                    }
                }
            )
        )
    }
}

#Preview {
    FeedingRejectionReasonAlert(onCancel: { }, onReject: { _ in })
        .padding()
        .environmentObject(StyleDefaultEngine() as StyleEngine)
}
