// swiftlint:disable all
import Amplify
import Foundation

public enum FeedingPointStatus: String, EnumPersistable {
  case fed
  case pending
  case starved
}