// swiftlint:disable all
import Amplify
import Foundation

extension LanguagesSetting {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case value
    case createdAt
    case updatedAt
    case createdBy
    case updatedBy
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let languagesSetting = LanguagesSetting.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "LanguagesSettings"
    
    model.fields(
      .id(),
      .field(languagesSetting.name, is: .required, ofType: .string),
      .field(languagesSetting.value, is: .required, ofType: .string),
      .field(languagesSetting.createdAt, is: .required, ofType: .dateTime),
      .field(languagesSetting.updatedAt, is: .required, ofType: .dateTime),
      .field(languagesSetting.createdBy, is: .optional, ofType: .string),
      .field(languagesSetting.updatedBy, is: .optional, ofType: .string)
    )
    }
}