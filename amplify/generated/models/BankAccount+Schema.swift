// swiftlint:disable all
import Amplify
import Foundation

extension BankAccount {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case value
    case icon
    case enabled
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let bankAccount = BankAccount.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "BankAccounts"
    
    model.fields(
      .id(),
      .field(bankAccount.name, is: .required, ofType: .string),
      .field(bankAccount.value, is: .required, ofType: .string),
      .field(bankAccount.icon, is: .required, ofType: .string),
      .field(bankAccount.enabled, is: .required, ofType: .bool),
      .field(bankAccount.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(bankAccount.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}