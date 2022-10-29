import Foundation

public protocol PhoneNumberRegionRecognizable: AnyObject {
    func processRegion(_ string: String)  -> Region?
    func processNumber(_ string: String)  -> String?
}

public final class PhoneNumberRegionProcessor: PhoneNumberRegionRecognizable {
    // MARK: - Properties
    private let allRegions: [Region]

    // MARK: - Initialization
    public init() {
        allRegions = Region.allCases
    }

    // MARK: - Public methods
    public func processRegion(_ string: String)  -> Region? {
        let normalizedPhoneNumber = normalizePhoneNumber(string)
        
        return allRegions.first { region in
            guard normalizedPhoneNumber.hasPrefix(region.phoneNumberCode) else { return false }
            let phoneWithoutCode = normalizedPhoneNumber.removePrefix(region.phoneNumberCode)
            return region.phoneNumberDigitsCount.contains(phoneWithoutCode.count)
        }
    }

    public func processNumber(_ string: String)  -> String? {
        let normalizedPhoneNumber = normalizePhoneNumber(string)
        if let region = processRegion(normalizedPhoneNumber) {
            return normalizedPhoneNumber.removePrefix(region.phoneNumberCode)
        } else {
            return nil
        }
    }

    // MARK: - Private methods
    private func normalizePhoneNumber(_ string: String) -> String {
        let pureString = string.replacingOccurrences(
            of: "[^0-9|+]",
            with: "",
            options: .regularExpression
        )

        if !pureString.hasPrefix("+") {
            return "+" + pureString
        }
        
        return pureString
    }
}
