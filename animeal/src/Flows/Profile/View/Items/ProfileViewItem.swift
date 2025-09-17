// System
import Foundation

// SDK
import Common
import UIComponents

protocol ProfileViewItemProtocol {
    var identifier: String { get }
    var type: ProfileItemType { get }
    var state: ProfileItemState { get }
    var isEditable: Bool { get }
    var title: String { get }
}

protocol ProfileViewTextFieldProtocol: ProfileViewItemProtocol {
    var formatter: DefaultTextInputFormatter? { get }
    var content: TextFieldContainerView.Model { get }
}

protocol ProfileViewAgeConsentProtocol: ProfileViewItemProtocol {
    var ageConsentModel: AgeConsentView.AgeConsentViewModel { get }
}

struct ProfileViewItemsSnapshot {
    let resetPreviousItems: Bool
    let viewItems: [ProfileViewItemProtocol]
}

struct ProfileTextFieldViewItem: ProfileViewTextFieldProtocol {
    let identifier: String
    let type: ProfileItemType
    let state: ProfileItemState
    let formatter: DefaultTextInputFormatter?
    let isEditable: Bool
    let title: String
    let content: TextFieldContainerView.Model
}

struct ProfileAgeConsentViewItem: ProfileViewAgeConsentProtocol {
    let identifier: String
    let type: ProfileItemType
    let state: ProfileItemState
    let isEditable: Bool
    let title: String
    let ageConsentModel: AgeConsentView.AgeConsentViewModel
}
