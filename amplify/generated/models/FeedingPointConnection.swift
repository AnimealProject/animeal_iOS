// swiftlint:disable all
import Amplify
import Foundation

public struct FeedingPointConnection: Embeddable {
  var items: [FeedingPoint]
  var total: Int?
  var nextToken: String?
}