// swiftlint:disable all
import Amplify
import Foundation

public struct Point: Embeddable {
  var type: String
  var coordinates: [Double]
}