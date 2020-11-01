// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "6b76663d1bfdd3b0f327f678a930531e"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Location.self)
    ModelRegistry.register(modelType: Juvenile.self)
    ModelRegistry.register(modelType: Behavior.self)
    ModelRegistry.register(modelType: Post.self)
    ModelRegistry.register(modelType: Purchase.self)
  }
}