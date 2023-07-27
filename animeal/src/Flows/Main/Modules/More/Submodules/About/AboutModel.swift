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
        // swiftlint:disable line_length
        return AboutModel(
            contentText: """
Who are we?
Animal Project was founded in 2020 by animal lovers with different professions and experiences. For decades, our team members  have been independently helping strays and raising awareness through personal channels.

What is our goal?
We exist so that dogs and cats no longer have to live in the streets of Georgia. Our goal is to create a habitable, comfortable environment for companion animals and raise awareness within our communities.

How are we working on this goal?
Our team heavily relies on international best practices and experience. Our areas of work include:
· Raising social awareness;
· Advocating with the government;
· Charitable and humanitarian projects in collaboration with the private sector, donor organizations, and local communities
""",
            links: AboutLink.allCases,
            appVersion: "\(L10n.About.appVersion) \(AppInfo.appVersion)"
            // swiftlint:enable line_length
        )
    }
}
