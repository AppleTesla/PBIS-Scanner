// swiftlint:disable all
import Amplify
import Foundation

public struct Purchase: Model {
  public let id: String
  public var name: String
  public var quantity: Int
  public var unit_price: Int
  
  public init(id: String = UUID().uuidString,
      name: String,
      quantity: Int,
      unit_price: Int) {
      self.id = id
      self.name = name
      self.quantity = quantity
      self.unit_price = unit_price
  }
}