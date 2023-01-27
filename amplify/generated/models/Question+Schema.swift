// swiftlint:disable all
import Amplify
import Foundation

extension Question {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case value
    case answer
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
    let question = Question.keys
    
    model.authRules = [
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Administrator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Moderator"], provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .groups, groupClaim: "cognito:groups", groups: ["Volunteer"], provider: .userPools, operations: [.read]),
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .read, .update, .delete]),
      rule(allow: .public, provider: .apiKey, operations: [.create, .update, .delete, .read]),
      rule(allow: .private, operations: [.read])
    ]
    
    model.pluralName = "Questions"
    
    model.fields(
      .id(),
      .field(question.value, is: .optional, ofType: .string),
      .field(question.answer, is: .optional, ofType: .string),
      .field(question.i18n, is: .optional, ofType: .embeddedCollection(of: QuestionI18n.self)),
      .field(question.createdAt, is: .required, ofType: .dateTime),
      .field(question.updatedAt, is: .required, ofType: .dateTime),
      .field(question.createdBy, is: .optional, ofType: .string),
      .field(question.updatedBy, is: .optional, ofType: .string),
      .field(question.owner, is: .optional, ofType: .string)
    )
    }
}