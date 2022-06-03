// swiftlint:disable all
import Amplify
import Foundation

extension MedicationI18n {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case name
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let medicationI18n = MedicationI18n.keys
    
    model.pluralName = "MedicationI18ns"
    
    model.fields(
      .field(medicationI18n.name, is: .required, ofType: .string)
    )
    }
}