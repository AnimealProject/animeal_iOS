import Foundation

enum BackendEnvironment: String, CaseIterable {
    case dev
    case test

    enum ConfigurationError: Error {
        case missingConfiguration(String)
    }

    private enum Constants {
        static let unknownName = "unknown"
        static let environmentResource = "backend_env"
        static let environmentResourceExtension = "txt"
        static let configurationResourcePrefix = "amplifyconfiguration-"
        static let configurationResourceExtension = "json"
        static let overrideKey = "qa.backendEnvironmentOverride"
    }

    static var buildTime: BackendEnvironment? {
        guard
            let url = Bundle.main.url(
                forResource: Constants.environmentResource,
                withExtension: Constants.environmentResourceExtension
            ),
            let raw = try? String(contentsOf: url, encoding: .utf8)
        else { return nil }
        return BackendEnvironment(rawValue: raw.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    static var active: BackendEnvironment? {
        #if QA_MENU
        return runtimeOverride ?? buildTime
        #else
        return buildTime
        #endif
    }

    static var activeName: String {
        active?.rawValue ?? Constants.unknownName
    }

    static var activeConfigurationURL: URL? {
        active?.configurationURL
    }

    var configurationURL: URL? {
        Bundle.main.url(
            forResource: Constants.configurationResourcePrefix + rawValue,
            withExtension: Constants.configurationResourceExtension
        )
    }

    static var apiHost: String? {
        guard
            let url = activeConfigurationURL,
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let api = json["api"] as? [String: Any],
            let plugins = api["plugins"] as? [String: Any],
            let apiPlugin = plugins["awsAPIPlugin"] as? [String: Any],
            let animealApi = apiPlugin["animeal"] as? [String: Any],
            let endpoint = animealApi["endpoint"] as? String
        else { return nil }
        return URL(string: endpoint)?.host
    }

    #if QA_MENU
    static var runtimeOverride: BackendEnvironment? {
        get {
            guard
                let value = UserDefaults.standard.string(forKey: Constants.overrideKey),
                let environment = BackendEnvironment(rawValue: value),
                environment.configurationURL != nil
            else { return nil }
            return environment
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: Constants.overrideKey)
        }
    }
    #endif
}
