// swiftlint:disable all
import Amplify
import Foundation

extension Favourite {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userId
    case feedingPointId
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let favourite = Favourite.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.create, .read, .update, .delete])
    ]
    
    model.pluralName = "Favourites"
    
    model.attributes(
      .index(fields: ["userId", "feedingPointId"], name: "byUserId"),
      .index(fields: ["feedingPointId", "userId"], name: "byFeedingPointId")
    )
    
    model.fields(
      .id(),
      .field(favourite.userId, is: .required, ofType: .string),
      .field(favourite.feedingPointId, is: .required, ofType: .string),
      .field(favourite.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(favourite.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}