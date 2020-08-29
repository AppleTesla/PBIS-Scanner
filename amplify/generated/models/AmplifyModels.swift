// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "3fec6110beb70391773ebcd93640c5ad"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Juvenile.self)
  }
}