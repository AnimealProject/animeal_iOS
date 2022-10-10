// swiftlint:disable all
import Amplify
import Foundation

extension Pet {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case images
    case breed
    case color
    case chipNumber
    case vaccinatedAt
    case yearOfBirth
    case caretaker
    case i18n
    case createdAt
    case updatedAt
    case createdBy
    case updatedBy
    case owner
    case feedingPoints
    case category
    case medications
    case users
    case cover
    case petCategoryId
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let pet = Pet.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "Pets"
    
    model.fields(
      .id(),
      .field(pet.name, is: .required, ofType: .string),
      .field(pet.images, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(pet.breed, is: .required, ofType: .string),
      .field(pet.color, is: .required, ofType: .string),
      .field(pet.chipNumber, is: .required, ofType: .string),
      .field(pet.vaccinatedAt, is: .required, ofType: .dateTime),
      .field(pet.yearOfBirth, is: .required, ofType: .dateTime),
      .field(pet.caretaker, is: .optional, ofType: .embedded(type: Caretaker.self)),
      .field(pet.i18n, is: .optional, ofType: .embeddedCollection(of: PetI18n.self)),
      .field(pet.createdAt, is: .required, ofType: .dateTime),
      .field(pet.updatedAt, is: .required, ofType: .dateTime),
      .field(pet.createdBy, is: .optional, ofType: .string),
      .field(pet.updatedBy, is: .optional, ofType: .string),
      .field(pet.owner, is: .optional, ofType: .string),
      .hasMany(pet.feedingPoints, is: .optional, ofType: RelationPetFeedingPoint.self, associatedWith: RelationPetFeedingPoint.keys.pet),
      .hasOne(pet.category, is: .required, ofType: Category.self, associatedWith: Category.keys.id, targetName: "petCategoryId"),
      .hasMany(pet.medications, is: .optional, ofType: Medication.self, associatedWith: Medication.keys.pet),
      .hasMany(pet.users, is: .optional, ofType: RelationUserPet.self, associatedWith: RelationUserPet.keys.pet),
      .field(pet.cover, is: .optional, ofType: .string),
      .field(pet.petCategoryId, is: .required, ofType: .string)
    )
    }
}