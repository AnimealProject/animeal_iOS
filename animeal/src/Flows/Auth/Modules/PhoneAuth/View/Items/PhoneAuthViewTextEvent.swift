import Foundation

enum PhoneAuthViewTextEvent {
    case beginEditing(String, String?)
    case shouldChangeCharactersIn(String, String?, NSRange, String)
    case endEditing(String, String?)
}
