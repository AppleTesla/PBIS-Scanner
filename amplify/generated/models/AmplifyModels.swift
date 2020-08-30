// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "6526f67e88f7e72dbb70ee300447bad4"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Location.self)
    ModelRegistry.register(modelType: Juvenile.self)
    ModelRegistry.register(modelType: Behavior.self)
  }
}