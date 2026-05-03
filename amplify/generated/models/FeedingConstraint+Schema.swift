// swiftlint:disable all
import Amplify
import Foundation

extension FeedingConstraint {
  // MARK: - CodingKeys
  public enum CodingKeys: String, ModelKey {
    case id
    case feedingHistoryId
    case createdAt
    case updatedAt
  }

  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema

  public static let schema = defineSchema { model in
    let feedingConstraint = FeedingConstraint.keys

    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]

    model.listPluralName = "FeedingConstraints"
    model.syncPluralName = "FeedingConstraints"

    model.fields(
      .id(),
      .field(feedingConstraint.feedingHistoryId, is: .optional, ofType: .string),
      .field(feedingConstraint.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(feedingConstraint.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
  }
}
