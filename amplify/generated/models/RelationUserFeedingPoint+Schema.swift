// swiftlint:disable all
import Amplify
import Foundation

extension RelationUserFeedingPoint {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userId
    case feedingPoint
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let relationUserFeedingPoint = RelationUserFeedingPoint.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "RelationUserFeedingPoints"
    
    model.attributes(
      .index(fields: ["userId", "feedingPointId"], name: "byUserId"),
      .index(fields: ["feedingPointId", "userId"], name: "byFeedingPointId")
    )
    
    model.fields(
      .id(),
      .field(relationUserFeedingPoint.userId, is: .required, ofType: .string),
      .belongsTo(relationUserFeedingPoint.feedingPoint, is: .required, ofType: FeedingPoint.self, targetName: "feedingPointId"),
      .field(relationUserFeedingPoint.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(relationUserFeedingPoint.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}