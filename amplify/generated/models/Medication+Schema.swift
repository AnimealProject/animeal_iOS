// swiftlint:disable all
import Amplify
import Foundation

extension Medication {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case pet
    case date
    case i18n
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let medication = Medication.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "Medications"
    
    model.attributes(
      .index(fields: ["petId", "date"], name: "byPetId")
    )
    
    model.fields(
      .id(),
      .field(medication.name, is: .required, ofType: .string),
      .belongsTo(medication.pet, is: .required, ofType: Pet.self, targetName: "petId"),
      .field(medication.date, is: .required, ofType: .dateTime),
      .field(medication.i18n, is: .optional, ofType: .embeddedCollection(of: MedicationI18n.self)),
      .field(medication.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(medication.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}