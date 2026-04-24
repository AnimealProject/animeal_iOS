//
//  LinkDetector.swift
//  Common
//
//  Created by Giorgi Amiranashvili on 23/04/2026.
//

import Foundation

public protocol LinkDetector {
    /// Detects URLs within the provided text.
    /// - Returns: An array of detected links with their ranges in the original string.
    func detectLinks(in text: String) -> [DetectedLink]
}

public struct DetectedLink: Equatable {
    public let url: URL
    public let range: Range<String.Index>

    public init(url: URL, range: Range<String.Index>) {
        self.url = url
        self.range = range
    }
}
