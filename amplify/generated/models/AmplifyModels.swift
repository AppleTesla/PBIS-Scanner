// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "5541c752a1b0ab32c980bab2fc6936b3"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Location.self)
    ModelRegistry.register(modelType: Juvenile.self)
    ModelRegistry.register(modelType: Queue.self)
    ModelRegistry.register(modelType: Behavior.self)
  }
}