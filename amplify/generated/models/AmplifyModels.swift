// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "a97441b1272cf47a1ee972bc60cfda50"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Location.self)
    ModelRegistry.register(modelType: Juvenile.self)
    ModelRegistry.register(modelType: Behavior.self)
    ModelRegistry.register(modelType: Post.self)
    ModelRegistry.register(modelType: Purchase.self)
    ModelRegistry.register(modelType: Transaction.self)
  }
}