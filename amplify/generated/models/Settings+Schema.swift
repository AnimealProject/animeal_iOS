// swiftlint:disable all
import Amplify
import Foundation

extension Settings {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case key
    case value
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let settings = Settings.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.listPluralName = "Settings"
    model.syncPluralName = "Settings"
    
    model.fields(
      .id(),
      .field(settings.key, is: .required, ofType: .string),
      .field(settings.value, is: .required, ofType: .string),
      .field(settings.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(settings.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}