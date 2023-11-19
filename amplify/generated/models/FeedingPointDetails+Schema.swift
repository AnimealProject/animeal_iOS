// swiftlint:disable all
import Amplify
import Foundation

extension FeedingPointDetails {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case address
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let feedingPointDetails = FeedingPointDetails.keys
    
    model.listPluralName = "FeedingPointDetails"
    model.syncPluralName = "FeedingPointDetails"
    
    model.fields(
      .field(feedingPointDetails.address, is: .required, ofType: .string)
    )
    }
}