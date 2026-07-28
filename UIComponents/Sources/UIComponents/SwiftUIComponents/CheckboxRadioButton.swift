import SwiftUI
import Style

public struct CheckboxRadioButton: View {
    let checkboxSelectedAsset: ImageAsset
    let checkboxUnselectedAsset: ImageAsset
    let checkboxText: String

    @Binding var isSelected: Bool

    public init(
        checkboxSelectedAsset: ImageAsset,
        checkboxUnselectedAsset: ImageAsset,
        checkboxText: String,
        isSelected: Binding<Bool>
    ) {
        self.checkboxSelectedAsset = checkboxSelectedAsset
        self.checkboxUnselectedAsset = checkboxUnselectedAsset
        self.checkboxText = checkboxText
        self._isSelected = isSelected
    }

    public var body: some View {
        HStack {
            Button(
                action: {
                    isSelected.toggle()
                },
                label: {
                    Image(asset: isSelected ? checkboxSelectedAsset : checkboxUnselectedAsset)
                }
            )
            Text(checkboxText)
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var isFirstSelected = true
        @State private var isSecondSelected = false

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                CheckboxRadioButton(
                    checkboxSelectedAsset: Asset.Images.checkboxRadioSelected,
                    checkboxUnselectedAsset: Asset.Images.checkboxRadioUnselected,
                    checkboxText: "No food",
                    isSelected: $isFirstSelected
                )
                CheckboxRadioButton(
                    checkboxSelectedAsset: Asset.Images.checkboxRadioSelected,
                    checkboxUnselectedAsset: Asset.Images.checkboxRadioUnselected,
                    checkboxText: "Bad photo quality",
                    isSelected: $isSecondSelected
                )
            }
            .padding()
        }
    }

    return PreviewContainer()
}
