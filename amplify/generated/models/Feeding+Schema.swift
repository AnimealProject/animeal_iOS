// swiftlint:disable all
import Amplify
import Foundation

extension Feeding {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userId
    case images
    case status
    case createdAt
    case updatedAt
    case createdBy
    case updatedBy
    case owner
    case feedingPoint
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let feeding = Feeding.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "Feedings"
    
    model.fields(
      .id(),
      .field(feeding.userId, is: .required, ofType: .string),
      .field(feeding.images, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(feeding.status, is: .required, ofType: .enum(type: FeedingStatus.self)),
      .field(feeding.createdAt, is: .required, ofType: .dateTime),
      .field(feeding.updatedAt, is: .required, ofType: .dateTime),
      .field(feeding.createdBy, is: .optional, ofType: .string),
      .field(feeding.updatedBy, is: .optional, ofType: .string),
      .field(feeding.owner, is: .optional, ofType: .string),
      .belongsTo(feeding.feedingPoint, is: .required, ofType: FeedingPoint.self, targetName: "feedingPointFeedingsId")
    )
    }
}