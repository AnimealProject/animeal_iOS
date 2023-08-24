// System
import Foundation

// SDK
import Services

protocol VerificationModelWorker: AnyObject {
    @discardableResult
    func confirmCode(
        _ code: VerificationModelCode,
        forAttribute attribute: VerificationModelAttribute
    ) async throws -> VerificationModelNextStep

    @discardableResult
    func resendCode(
        forAttribute attribute: VerificationModelAttribute
    ) async throws -> VerificationModelNextStep

    @discardableResult
    func resendAttrUpdate(
        forAttribute attribute: VerificationModelAttribute
    ) async throws -> VerificationModelNextStep
}
