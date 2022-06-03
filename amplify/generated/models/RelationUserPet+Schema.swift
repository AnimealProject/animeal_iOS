// swiftlint:disable all
import Amplify
import Foundation

extension RelationUserPet {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userId
    case pet
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let relationUserPet = RelationUserPet.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "RelationUserPets"
    
    model.attributes(
      .index(fields: ["userId", "petId"], name: "byUserId"),
      .index(fields: ["petId", "userId"], name: "byPetId")
    )
    
    model.fields(
      .id(),
      .field(relationUserPet.userId, is: .required, ofType: .string),
      .belongsTo(relationUserPet.pet, is: .required, ofType: Pet.self, targetName: "petId"),
      .field(relationUserPet.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(relationUserPet.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}