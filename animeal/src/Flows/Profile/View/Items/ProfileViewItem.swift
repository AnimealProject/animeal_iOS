// System
import Foundation

// SDK
import Common
import UIComponents

struct ProfileViewItem {
    let identifier: String
    let type: ProfileItemType
    let state: ProfileItemState
    let formatter: DefaultTextInputFormatter?
    let isEditable: Bool
    let title: String
    let content: TextFieldContainerView.Model
}
