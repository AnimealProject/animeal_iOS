// swiftlint:disable all
import Amplify
import Foundation

extension Language {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case code
    case createdAt
    case updatedAt
    case createdBy
    case updatedBy
    case direction
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let language = Language.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.listPluralName = "Languages"
    model.syncPluralName = "Languages"
    
    model.fields(
      .id(),
      .field(language.name, is: .required, ofType: .string),
      .field(language.code, is: .required, ofType: .string),
      .field(language.createdAt, is: .required, ofType: .dateTime),
      .field(language.updatedAt, is: .required, ofType: .dateTime),
      .field(language.createdBy, is: .optional, ofType: .string),
      .field(language.updatedBy, is: .optional, ofType: .string),
      .field(language.direction, is: .required, ofType: .string)
    )
    }
}