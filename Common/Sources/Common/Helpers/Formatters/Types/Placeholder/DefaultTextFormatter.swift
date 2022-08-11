import Foundation

open class DefaultTextFormatter: TextFormatter, TextUnformatter {
    // MARK: - Properties
    public let textPattern: String
    public let patternSymbol: Character
  
    // MARK: - Life cycle
    public init(
        textPattern: String,
        patternSymbol: Character = "x"
    ) {
        self.textPattern = textPattern
        self.patternSymbol = patternSymbol
    }

    open func format(_ unformattedText: String?) -> String? {
        guard let unformattedText = unformattedText else { return nil }
        var formatted = ""
        var unformattedIndex = 0
        var patternIndex = 0
    
        while patternIndex < textPattern.count && unformattedIndex < unformattedText.count {
            guard let patternCharacter = textPattern.characterAt(patternIndex) else { break }
            if patternCharacter == patternSymbol {
                if let unformattedCharacter = unformattedText.characterAt(unformattedIndex) {
                    formatted.append(unformattedCharacter)
                }
                unformattedIndex += 1
            } else {
                formatted.append(patternCharacter)
            }
            patternIndex += 1
        }
        return formatted
    }

    open func unformat(_ formatted: String?) -> String? {
        guard let formatted = formatted else { return nil }
        var unformatted = String()
        var formattedIndex = 0
    
        while formattedIndex < formatted.count {
            if let formattedCharacter = formatted.characterAt(formattedIndex) {
                if formattedIndex >= textPattern.count {
                    unformatted.append(formattedCharacter)
                } else if formattedCharacter != textPattern.characterAt(formattedIndex)
                            || formattedCharacter == patternSymbol {
                    unformatted.append(formattedCharacter)
                }
                formattedIndex += 1
            }
        }
        return unformatted
    }
  
    public struct Constants {
        public static let defaultPatternSymbol: Character = "#"
    }
}
