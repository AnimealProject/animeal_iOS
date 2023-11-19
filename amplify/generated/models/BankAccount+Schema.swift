// swiftlint:disable all
import Amplify
import Foundation

extension BankAccount {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case value
    case cover
    case images
    case enabled
    case createdBy
    case updatedBy
    case owner
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
    
    model.listPluralName = "BankAccounts"
    model.syncPluralName = "BankAccounts"
    
    model.fields(
      .id(),
      .field(bankAccount.name, is: .required, ofType: .string),
      .field(bankAccount.value, is: .required, ofType: .string),
      .field(bankAccount.cover, is: .required, ofType: .string),
      .field(bankAccount.images, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(bankAccount.enabled, is: .required, ofType: .bool),
      .field(bankAccount.createdBy, is: .optional, ofType: .string),
      .field(bankAccount.updatedBy, is: .optional, ofType: .string),
      .field(bankAccount.owner, is: .optional, ofType: .string),
      .field(bankAccount.createdAt, is: .required, ofType: .dateTime),
      .field(bankAccount.updatedAt, is: .required, ofType: .dateTime)
    )
    }
}