// swiftlint:disable all
import Amplify
import Foundation

public struct Purchase: Model {
  public let id: String
  public var name: String
  public var quantity: Int
  public var unit_price: String
  public var transactionPurchasesId: String?
  
  public init(id: String = UUID().uuidString,
      name: String,
      quantity: Int,
      unit_price: String,
      transactionPurchasesId: String? = nil) {
      self.id = id
      self.name = name
      self.quantity = quantity
      self.unit_price = unit_price
      self.transactionPurchasesId = transactionPurchasesId
  }
}