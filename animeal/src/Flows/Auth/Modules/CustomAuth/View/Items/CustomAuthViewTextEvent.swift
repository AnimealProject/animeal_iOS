import Foundation

enum CustomAuthViewTextEvent {
    case beginEditing(String, String?)
    case didChange(String, String?)
    case shouldChangeCharactersIn(String, String?, NSRange, String)
    case endEditing(String, String?)
}
