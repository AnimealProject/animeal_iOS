// swiftlint:disable all
import Amplify
import Foundation

extension FeedingUsers {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case attributes
    case createdAt
    case updatedAt
    case owner
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let feedingUsers = FeedingUsers.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "FeedingUsers"
    
    model.fields(
      .id(),
      .field(feedingUsers.attributes, is: .optional, ofType: .embeddedCollection(of: UserAttribute.self)),
      .field(feedingUsers.createdAt, is: .optional, ofType: .string),
      .field(feedingUsers.updatedAt, is: .optional, ofType: .string),
      .field(feedingUsers.owner, is: .optional, ofType: .string)
    )
    }
}