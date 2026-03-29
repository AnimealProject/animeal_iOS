import Foundation
import Style
import UIComponents

// sourcery: AutoMockable
protocol QuestionViewMappable {
    func mapQuestion(_ input: FAQModel.Question) -> FAQViewItem
}

final class QuestionViewMapper: QuestionViewMappable {
    func mapQuestion(_ input: FAQModel.Question) -> FAQViewItem {
        let attributedAnswer = attributedStringWithLinks(from: input.answer.trimmingWhitespaces())
        return FAQViewItem(
            id: input.id,
            question: input.question.trimmingWhitespaces(),
            answer: attributedAnswer,
            collapsed: true
        )
    }
}

struct FAQViewItem: Identifiable {
    let id: String
    let question: String
    let answer: AttributedString
    let collapsed: Bool
}

private extension QuestionViewMapper {
    func attributedStringWithLinks(from text: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        applyDetectedLinks(to: &attributed, in: text)
        applyBareDomainLinks(to: &attributed, in: text)
        
        return attributed
    }
    
    func applyDetectedLinks(to attributed: inout AttributedString, in text: String) {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return }
        let matches = detector.matches(in: text, range: NSRange(text.startIndex..., in: text))
        for match in matches {
            guard let url = match.url,
                  let stringRange = Range(match.range, in: text),
                  let attributedRange = Range(stringRange, in: attributed) else { continue }
            
            attributed[attributedRange].link = url
        }
    }
    
    func applyBareDomainLinks(to attributed: inout AttributedString, in text: String) {
        let pattern = #"\b(?:[A-Za-z0-9-]+\.)+[A-Za-z]{2,}\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        for match in matches {
            guard let stringRange = Range(match.range, in: text),
                  let attributedRange = Range(stringRange, in: attributed) else { continue }
            
            let matchedText = String(text[stringRange])
            if attributed[attributedRange].link != nil {
                continue
            }
            guard let url = URL(string: "https://\(matchedText)") else { continue }
            attributed[attributedRange].link = url
        }
    }
}
