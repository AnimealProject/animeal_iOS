import Foundation

enum ProfileModelIntermediateStep {
    case proceed
    case update
    case cancel(() async throws -> Void)
}
