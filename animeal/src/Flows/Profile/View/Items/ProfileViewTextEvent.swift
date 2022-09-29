import Foundation

enum ProfileViewTextEvent {
    case beginEditing(String, String?)
    case didChange(String, String?)
    case shouldChangeCharactersIn(String, String?, NSRange, String)
    case endEditing(String, String?)
}

enum ProfileViewItemEvent {
    case changeText(ProfileViewTextEvent)
    case changeDate(String, Date)
}
