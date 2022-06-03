// swiftlint:disable all
import Amplify
import Foundation

extension FeedingPointConnection {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case items
    case total
    case nextToken
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let feedingPointConnection = FeedingPointConnection.keys
    
    model.pluralName = "FeedingPointConnections"
    
    model.fields(
      .field(feedingPointConnection.items, is: .required, ofType: .collection(of: FeedingPoint.self)),
      .field(feedingPointConnection.total, is: .optional, ofType: .int),
      .field(feedingPointConnection.nextToken, is: .optional, ofType: .string)
    )
    }
}