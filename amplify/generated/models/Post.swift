// swiftlint:disable all
import Amplify
import Foundation

public struct Post: Model {
  public let id: String
  public var juvenile_id: String
  public var behavior_id: String
  
  public init(id: String = UUID().uuidString,
      juvenile_id: String,
      behavior_id: String) {
      self.id = id
      self.juvenile_id = juvenile_id
      self.behavior_id = behavior_id
  }
}