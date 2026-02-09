import Foundation
import Style
import Common
import SwiftUI

final class FAQViewModel: FAQViewModelLifeCycle, FAQViewInteraction, FAQViewState, ObservableObject {

    // MARK: - Dependencies
    private let model: FAQModelProtocol
    private let coordinator: MorePartitionCoordinatable
    private let mapper: QuestionViewMappable

    @Published var faqItems: [FAQViewItem] = []
    let footerText: AttributedString = {
        let email = "hi@animalproject.ge"
        var text = AttributedString(
            L10n.Faq.Footer.text(email)
        )

        if let range = text.range(of: email) {
            text[range].link = URL(string: "mailto:\(email)")
            text[range].foregroundColor = .blue
            text[range].underlineStyle = .single
        }

        return text
    }()

    // MARK: - Initialization
    init(
        model: FAQModelProtocol,
        coordinator: MorePartitionCoordinatable,
        mapper: QuestionViewMappable = QuestionViewMapper()
    ) {
        self.model = model
        self.coordinator = coordinator
        self.mapper = mapper
        setup()
    }

    // MARK: - Life cycle
    func setup() {
    }

    func load() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let questions = try await self.model.fetchQuestions()
                self.faqItems = questions.map(self.mapper.mapQuestion)
            } catch {
                self.coordinator.displayAlert(message: error.localizedDescription)
            }
        }
    }

    // MARK: - Interaction
    @MainActor
    func handleActionEvent(_ event: FAQViewActionEvent) {
        switch event {
        case .back:
            coordinator.routeTo(.back)
        case .toggleItem(let id):
            proceedItemCollapsedState(id: id)
        }
    }

    // MARK: - Private

    private func proceedItemCollapsedState(id: FAQViewItem.ID) {
        self.faqItems = faqItems.map {
            $0.makeCollapsed(for: id)
        }
    }
}

private extension FAQViewItem {
    func makeCollapsed(for collapsingId: String) -> Self {
        FAQViewItem(
            id: id,
            question: question,
            answer: answer,
            collapsed: id == collapsingId ? !collapsed : true
        )
    }
}
