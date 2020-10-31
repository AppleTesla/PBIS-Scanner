// swiftlint:disable all
import Amplify
import Foundation

public struct Transaction: Model {
  public let id: String
  public var claim_id: Int
  public var officer: String
  public var date: String
  public var subtotal: Int
  public var purchases: List<Purchase>?
  
  public init(id: String = UUID().uuidString,
      claim_id: Int,
      officer: String,
      date: String,
      subtotal: Int,
      purchases: List<Purchase>? = []) {
      self.id = id
      self.claim_id = claim_id
      self.officer = officer
      self.date = date
      self.subtotal = subtotal
      self.purchases = purchases
  }
}