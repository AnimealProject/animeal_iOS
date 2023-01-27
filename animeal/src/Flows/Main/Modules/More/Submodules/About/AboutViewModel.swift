import Foundation
import Style
import Common

final class AboutViewModel: AboutViewModelLifeCycle, AboutViewInteraction, AboutViewState {

    // MARK: - Dependencies
    private let model: AboutModelProtocol
    private let coordinator: MorePartitionCoordinatable
    private let linkOpener: LinkOpener

    // MARK: - Initialization
    init(
        model: AboutModelProtocol,
        coordinator: MorePartitionCoordinatable,
        linkOpener: LinkOpener
    ) {
        self.model = model
        self.coordinator = coordinator
        self.linkOpener = linkOpener
        setup()
    }

    // MARK: - Life cycle
    func setup() {
    }

    func load() {
        model.links = AboutLink.allCases
        model.contentText = AboutModel.previewModel.contentText
    }

    public var observableModel: AboutModelProtocol {
        return model
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: AboutViewActionEvent) {
        switch event {
        case .back:
            coordinator.routeTo(.back)

        case let .linkTapped(link):
            tryOpen(link: link)
        }
    }

    // MARK: - Private
    private func tryOpen(link: AboutLink) {
        if let linkedAppUrlString = link.appSchemeString,
           let linkedAppUrl = URL(string: linkedAppUrlString),
           linkOpener.canOpenUrl(linkedAppUrl) {
            linkOpener.open(linkedAppUrl)
        } else if let webUrlString = link.urlString,
                  let webUrl = URL(string: webUrlString) {
            linkOpener.open(webUrl)
        }
    }
}
