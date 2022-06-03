// swiftlint:disable all
import Amplify
import Foundation

extension RelationPetFeedingPoint {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case pet
    case feedingPoint
    case createdAt
    case updatedAt
    case owner
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let relationPetFeedingPoint = RelationPetFeedingPoint.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "RelationPetFeedingPoints"
    
    model.attributes(
      .index(fields: ["petId", "feedingPointId"], name: "byPetId"),
      .index(fields: ["feedingPointId", "petId"], name: "byFeedingPointId")
    )
    
    model.fields(
      .id(),
      .belongsTo(relationPetFeedingPoint.pet, is: .required, ofType: Pet.self, targetName: "petId"),
      .belongsTo(relationPetFeedingPoint.feedingPoint, is: .required, ofType: FeedingPoint.self, targetName: "feedingPointId"),
      .field(relationPetFeedingPoint.createdAt, is: .required, ofType: .dateTime),
      .field(relationPetFeedingPoint.updatedAt, is: .required, ofType: .dateTime),
      .field(relationPetFeedingPoint.owner, is: .optional, ofType: .string)
    )
    }
}