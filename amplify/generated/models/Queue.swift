// swiftlint:disable all
import Amplify
import Foundation

public struct Queue: Model {
  public let id: String
  public var juveniles: List<Juvenile>?
  
  public init(id: String = UUID().uuidString,
      juveniles: List<Juvenile> = []) {
      self.id = id
      self.juveniles = juveniles
  }
}