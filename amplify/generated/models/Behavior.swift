// swiftlint:disable all
import Amplify
import Foundation

public struct Behavior: Model {
  public let id: String
  public var title: String
  public var category: Category
  public var location: Location
  
  public init(id: String = UUID().uuidString,
      title: String,
      category: Category,
      location: Location) {
      self.id = id
      self.title = title
      self.category = category
      self.location = location
  }
}