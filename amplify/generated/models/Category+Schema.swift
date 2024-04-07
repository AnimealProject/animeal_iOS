// swiftlint:disable all
import Amplify
import Foundation

extension Category {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case icon
    case tag
    case i18n
    case createdAt
    case updatedAt
    case createdBy
    case updatedBy
    case owner
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let category = Category.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.listPluralName = "Categories"
    model.syncPluralName = "Categories"
    
    model.fields(
      .id(),
      .field(category.name, is: .required, ofType: .string),
      .field(category.icon, is: .required, ofType: .string),
      .field(category.tag, is: .required, ofType: .enum(type: CategoryTag.self)),
      .field(category.i18n, is: .optional, ofType: .embeddedCollection(of: CategoryI18n.self)),
      .field(category.createdAt, is: .required, ofType: .dateTime),
      .field(category.updatedAt, is: .required, ofType: .dateTime),
      .field(category.createdBy, is: .optional, ofType: .string),
      .field(category.updatedBy, is: .optional, ofType: .string),
      .field(category.owner, is: .optional, ofType: .string)
    )
    }
}