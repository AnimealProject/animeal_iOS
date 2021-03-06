// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "ceae3a58715243d643736ffece08ae9a"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: FeedingPoint.self)
    ModelRegistry.register(modelType: RelationPetFeedingPoint.self)
    ModelRegistry.register(modelType: Pet.self)
    ModelRegistry.register(modelType: Category.self)
    ModelRegistry.register(modelType: Medication.self)
    ModelRegistry.register(modelType: RelationUserPet.self)
    ModelRegistry.register(modelType: RelationUserFeedingPoint.self)
    ModelRegistry.register(modelType: Feeding.self)
    ModelRegistry.register(modelType: Settings.self)
    ModelRegistry.register(modelType: Language.self)
    ModelRegistry.register(modelType: LanguagesSetting.self)
    ModelRegistry.register(modelType: Favourites.self)
  }
}