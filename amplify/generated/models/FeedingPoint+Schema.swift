// swiftlint:disable all
import Amplify
import Foundation

extension FeedingPoint {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case description
    case city
    case street
    case address
    case images
    case point
    case location
    case region
    case neighborhood
    case distance
    case status
    case i18n
    case statusUpdatedAt
    case createdAt
    case updatedAt
    case createdBy
    case updatedBy
    case owner
    case pets
    case category
    case users
    case cover
    case feedingPointCategoryId
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let feedingPoint = FeedingPoint.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "FeedingPoints"
    
    model.fields(
      .id(),
      .field(feedingPoint.name, is: .required, ofType: .string),
      .field(feedingPoint.description, is: .required, ofType: .string),
      .field(feedingPoint.city, is: .required, ofType: .string),
      .field(feedingPoint.street, is: .required, ofType: .string),
      .field(feedingPoint.address, is: .required, ofType: .string),
      .field(feedingPoint.images, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(feedingPoint.point, is: .required, ofType: .embedded(type: Point.self)),
      .field(feedingPoint.location, is: .required, ofType: .embedded(type: Location.self)),
      .field(feedingPoint.region, is: .required, ofType: .string),
      .field(feedingPoint.neighborhood, is: .required, ofType: .string),
      .field(feedingPoint.distance, is: .required, ofType: .double),
      .field(feedingPoint.status, is: .required, ofType: .enum(type: FeedingPointStatus.self)),
      .field(feedingPoint.i18n, is: .optional, ofType: .embeddedCollection(of: FeedingPointI18n.self)),
      .field(feedingPoint.statusUpdatedAt, is: .required, ofType: .dateTime),
      .field(feedingPoint.createdAt, is: .required, ofType: .dateTime),
      .field(feedingPoint.updatedAt, is: .required, ofType: .dateTime),
      .field(feedingPoint.createdBy, is: .optional, ofType: .string),
      .field(feedingPoint.updatedBy, is: .optional, ofType: .string),
      .field(feedingPoint.owner, is: .optional, ofType: .string),
      .hasMany(feedingPoint.pets, is: .optional, ofType: RelationPetFeedingPoint.self, associatedWith: RelationPetFeedingPoint.keys.feedingPoint),
      .hasOne(feedingPoint.category, is: .optional, ofType: Category.self, associatedWith: Category.keys.id, targetName: "feedingPointCategoryId"),
      .hasMany(feedingPoint.users, is: .optional, ofType: RelationUserFeedingPoint.self, associatedWith: RelationUserFeedingPoint.keys.feedingPoint),
      .field(feedingPoint.cover, is: .optional, ofType: .string),
      .field(feedingPoint.feedingPointCategoryId, is: .optional, ofType: .string)
    )
    }
}