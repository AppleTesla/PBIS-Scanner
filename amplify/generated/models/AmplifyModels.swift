// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "788b8069812b70e7de15f734435d4237"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Location.self)
    ModelRegistry.register(modelType: Juvenile.self)
    ModelRegistry.register(modelType: Behavior.self)
    ModelRegistry.register(modelType: Post.self)
  }
}