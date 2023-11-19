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
    case feedingPointDetails
    case status
    case reason
    case moderatedBy
    case moderatedAt
    case assignedModerators
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
    
    model.listPluralName = "FeedingHistories"
    model.syncPluralName = "FeedingHistories"
    
    model.fields(
      .id(),
      .field(feedingHistory.userId, is: .required, ofType: .string),
      .field(feedingHistory.images, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(feedingHistory.createdAt, is: .required, ofType: .dateTime),
      .field(feedingHistory.updatedAt, is: .required, ofType: .dateTime),
      .field(feedingHistory.createdBy, is: .optional, ofType: .string),
      .field(feedingHistory.updatedBy, is: .optional, ofType: .string),
      .field(feedingHistory.owner, is: .optional, ofType: .string),
      .field(feedingHistory.feedingPointId, is: .required, ofType: .string),
      .field(feedingHistory.feedingPointDetails, is: .optional, ofType: .embedded(type: FeedingPointDetails.self)),
      .field(feedingHistory.status, is: .optional, ofType: .enum(type: FeedingStatus.self)),
      .field(feedingHistory.reason, is: .optional, ofType: .string),
      .field(feedingHistory.moderatedBy, is: .optional, ofType: .string),
      .field(feedingHistory.moderatedAt, is: .optional, ofType: .dateTime),
      .field(feedingHistory.assignedModerators, is: .optional, ofType: .embeddedCollection(of: String.self))
    )
    }
}