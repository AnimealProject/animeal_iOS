import Foundation
import Style
import UIComponents
import Common

// sourcery: AutoMockable
protocol QuestionViewMappable {
    func mapQuestion(_ input: FAQModel.Question) -> FAQViewItem
}

final class QuestionViewMapper: QuestionViewMappable {
    private let linkDetector: LinkDetector
    
    init(linkDetector: LinkDetector = DefaultLinkDetector()) {
        self.linkDetector = linkDetector
    }
    
    func mapQuestion(_ input: FAQModel.Question) -> FAQViewItem {
        let trimmedAnswer = input.answer.trimmingWhitespaces()
        return FAQViewItem(
            id: input.id,
            question: input.question.trimmingWhitespaces(),
            answer: makeMarkdownLinkedText(from: trimmedAnswer),
            collapsed: true
        )
    }
    
    /// Wraps detected URLs in markdown syntax so SwiftUI's Text(LocalizedStringKey:)
    /// renders them as tappable links while still respecting font/color modifiers.
    private func makeMarkdownLinkedText(from text: String) -> String {
        let links = linkDetector.detectLinks(in: text)
        guard !links.isEmpty else { return text }
        
        var result = text
        for link in links.sorted(by: { $0.range.lowerBound > $1.range.lowerBound }) {
            let matchedText = String(text[link.range])
            let markdown = "[\(matchedText)](\(link.url.absoluteString))"
            result.replaceSubrange(link.range, with: markdown)
        }
        return result
    }
}

struct FAQViewItem: Identifiable {
    let id: String
    let question: String
    let answer: String
    let collapsed: Bool
}
