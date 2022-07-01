import Foundation
import UIComponents

struct PhoneNumberProcessor: StringProcessable {

    // MARK: - Constants
    private enum Constants {
        static let maxPhoneNumberLength: Int = 12
        static let phoneMask: String = "+### ### ##-##-##"
        static let numberSign: Character = "#"
    }

    // MARK: - Dependencies
    private let mask: String
    private let maskReplacementCharacter: Character

    // MARK: - Initialization
    init(
        mask: String = Constants.phoneMask,
        maskReplacementCharacter: Character = Constants.numberSign
    ) {
        self.mask = mask
        self.maskReplacementCharacter = maskReplacementCharacter
    }

    // MARK: - Public methods
    func process(_ string: String) -> String {

        // Remove any character that is not a number
        let numbersOnly = string.components(
            separatedBy: CharacterSet.decimalDigits.inverted
        )
        .joined()

        // Check if user tries to paste a longer number
        if numbersOnly.count > Constants.maxPhoneNumberLength {
            let trimmedNumber = dropLastExtraChars(phoneNumber: numbersOnly)
            return applyMask(
                mask,
                on: trimmedNumber,
                replacementCharacter: maskReplacementCharacter
            )
        } else {
            return applyMask(
                mask,
                on: numbersOnly,
                replacementCharacter: maskReplacementCharacter
            )
        }
    }

    // MARK: - Private methods
    private func dropLastExtraChars(phoneNumber sourcePhoneNumber: String) -> String {
        let countOfExtraChars = abs(sourcePhoneNumber.count - Constants.maxPhoneNumberLength)
        return String(sourcePhoneNumber.dropLast(countOfExtraChars))
    }

    private func applyMask(_ mask: String, on string: String, replacementCharacter: Character) -> String {
        var pureString = string.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression
        )

        var charsToInsertLeft = pureString.count

        for index in 0 ..< mask.count {
            guard
                charsToInsertLeft > 0,
                index < pureString.count
            else {
                return pureString
            }

            let maskIndex = String.Index(utf16Offset: index, in: mask)
            let stringIndex = String.Index(utf16Offset: index, in: pureString)
            let maskCharacter = mask[safe: maskIndex]

            guard let maskCharToInsert = maskCharacter else {
                return pureString
            }

            guard maskCharToInsert != replacementCharacter else {
                continue
            }

            pureString.insert(maskCharToInsert, at: stringIndex)
            charsToInsertLeft -= 1
        }
        return pureString
    }
}
