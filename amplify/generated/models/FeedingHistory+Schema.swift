// swiftlint:disable all
import Amplify
import Foundation

extension FeedingHistory {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userId
    case images
    case createdAt
    case updatedAt
    case createdBy
    case updatedBy
    case owner
    case feedingPointId
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let feedingHistory = FeedingHistory.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "FeedingHistories"
    
    model.fields(
      .id(),
      .field(feedingHistory.userId, is: .required, ofType: .string),
      .field(feedingHistory.images, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(feedingHistory.createdAt, is: .required, ofType: .dateTime),
      .field(feedingHistory.updatedAt, is: .required, ofType: .dateTime),
      .field(feedingHistory.createdBy, is: .optional, ofType: .string),
      .field(feedingHistory.updatedBy, is: .optional, ofType: .string),
      .field(feedingHistory.owner, is: .optional, ofType: .string),
      .field(feedingHistory.feedingPointId, is: .required, ofType: .string)
    )
    }
}