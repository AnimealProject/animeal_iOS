// swiftlint:disable all
import Amplify
import Foundation

extension QuestionI18n {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case locale
    case value
    case answer
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let questionI18n = QuestionI18n.keys
    
    model.listPluralName = "QuestionI18ns"
    model.syncPluralName = "QuestionI18ns"
    
    model.fields(
      .field(questionI18n.locale, is: .required, ofType: .string),
      .field(questionI18n.value, is: .optional, ofType: .string),
      .field(questionI18n.answer, is: .optional, ofType: .string)
    )
    }
}