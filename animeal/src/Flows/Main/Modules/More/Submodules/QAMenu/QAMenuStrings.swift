import Foundation

enum QAMenuStrings {
    static let environmentPicker = "Environment"
    static let switchWarning = "Switching signs you out, clears local data and closes the app."
    static let switchAction = "Switch and close the app"
    static let cancel = "Cancel"
    static let unknownHost = "unknown host"

    static func backendSummary(environment: String, host: String) -> String {
        "Backend: \(environment) (\(host))"
    }

    static func switchConfirmation(_ environment: BackendEnvironment?) -> String {
        "Switch backend to \(environment?.rawValue ?? "")?"
    }
}
