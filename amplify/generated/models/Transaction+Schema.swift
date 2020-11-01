// swiftlint:disable all
import Amplify
import Foundation

extension Transaction {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case claim_id
    case officer
    case date
    case subtotal
    case purchases
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let transaction = Transaction.keys
    
    model.pluralName = "Transactions"
    
    model.fields(
      .id(),
      .field(transaction.claim_id, is: .required, ofType: .int),
      .field(transaction.officer, is: .required, ofType: .string),
      .field(transaction.date, is: .required, ofType: .string),
      .field(transaction.subtotal, is: .required, ofType: .int),
      .hasMany(transaction.purchases, is: .optional, ofType: Purchase.self, associatedWith: Purchase.keys.transaction)
    )
    }
}