//
//  DefaultLinkDetector.swift
//  Common
//
//  Created by Giorgi Amiranashvili on 23/04/2026.
//

import Foundation

public final class DefaultLinkDetector: LinkDetector {
    private let detector: NSDataDetector?
    
    public init() {
        self.detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        )
    }
    
    public func detectLinks(in text: String) -> [DetectedLink] {
        guard let detector else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        let matches = detector.matches(in: text, range: range)
        
        return matches.compactMap { match -> DetectedLink? in
            guard
                let url = match.url,
                let stringRange = Range(match.range, in: text)
            else { return nil }
            return DetectedLink(url: url, range: stringRange)
        }
    }
}
