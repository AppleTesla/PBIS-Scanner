// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "5610fa1b9fc66739aa8317feeb85452b"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Location.self)
    ModelRegistry.register(modelType: Juvenile.self)
    ModelRegistry.register(modelType: Behavior.self)
    ModelRegistry.register(modelType: Bucket.self)
    ModelRegistry.register(modelType: Post.self)
  }
}