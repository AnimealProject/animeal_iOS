// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "b28c19884f4fefbaacbd1d1df0a4297a"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Pet.self)
    ModelRegistry.register(modelType: Category.self)
    ModelRegistry.register(modelType: FeedingPoint.self)
    ModelRegistry.register(modelType: Feeding.self)
    ModelRegistry.register(modelType: FeedingUsers.self)
    ModelRegistry.register(modelType: FeedingHistory.self)
    ModelRegistry.register(modelType: RelationPetFeedingPoint.self)
    ModelRegistry.register(modelType: RelationUserFeedingPoint.self)
    ModelRegistry.register(modelType: RelationUserPet.self)
    ModelRegistry.register(modelType: Medication.self)
    ModelRegistry.register(modelType: Settings.self)
    ModelRegistry.register(modelType: Language.self)
    ModelRegistry.register(modelType: LanguagesSetting.self)
    ModelRegistry.register(modelType: Favourite.self)
    ModelRegistry.register(modelType: Question.self)
    ModelRegistry.register(modelType: BankAccount.self)
  }
}