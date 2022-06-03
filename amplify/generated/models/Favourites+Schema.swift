// swiftlint:disable all
import Amplify
import Foundation

extension Favourites {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userId
    case feedingPointId
    case feedingPoint
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let favourites = Favourites.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "Favourites"
    
    model.attributes(
      .index(fields: ["userId", "feedingPointId"], name: "byUserId"),
      .index(fields: ["feedingPointId", "userId"], name: "byFeedingPointId")
    )
    
    model.fields(
      .id(),
      .field(favourites.userId, is: .required, ofType: .string),
      .field(favourites.feedingPointId, is: .required, ofType: .string),
      .hasOne(favourites.feedingPoint, is: .required, ofType: FeedingPoint.self, associatedWith: FeedingPoint.keys.id, targetName: "feedingPointId"),
      .field(favourites.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(favourites.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}