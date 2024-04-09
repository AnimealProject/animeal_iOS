import Foundation

// MARK: - AboutModel
final class AboutModel: AboutModelProtocol, ObservableObject {

    // MARK: - Published properties
    @Published var contentText: String
    @Published var links: [AboutLink]
    @Published var appVersion: String

    // MARK: - Initialization
    init(contentText: String = "", links: [AboutLink] = [], appVersion: String = "") {
        self.contentText = contentText
        self.links = links
        self.appVersion = appVersion
    }
}

// MARK: - Preview
extension AboutModel {
    static var previewModel: AboutModel {
        return AboutModel(
            contentText: "\(L10n.More.aboutContent)",
            links: AboutLink.allCases,
            appVersion: "\(L10n.About.appVersion) \(AppInfo.appVersion) (\(AppInfo.appBuildNumber))"
        )
    }
}
