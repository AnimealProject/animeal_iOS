// System
import Foundation

enum LocalizationService {
    enum Language: String {
        case english = "en"
        case georgian = "ka"
    }

    static func activate() {
        object_setClass(Bundle.main, LocalizedBundle.self)
        LocalizedBundle.language = currentLanguage
    }

    /// The language the app's `L10n.*` strings actually resolve to — use this (not `Locale.current`)
    /// when configuring any other formatter (dates, numbers) that should match the app's displayed text,
    /// since the device's system locale can differ from the `en`/`ka` pair this app supports.
    static var currentLanguage: Language {
        Locale.preferredLanguages.first?.hasPrefix(Language.georgian.rawValue) == true ? .georgian : .english
    }

    static var currentLocale: Locale {
        Locale(identifier: currentLanguage.rawValue)
    }
}

/// Makes `Bundle.main.localizedString` resolve strings from the selected
/// language's `.lproj` instead of the system locale, so the app's language
/// can be switched without depending on the device's `.lproj` resolution order.
private final class LocalizedBundle: Bundle, @unchecked Sendable {
    static var language: LocalizationService.Language = .english

    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard
            let path = path(forResource: Self.language.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
