// swiftlint:disable all
import Amplify
import Foundation

extension Purchase {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case quantity
    case unit_price
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let purchase = Purchase.keys
    
    model.pluralName = "Purchases"
    
    model.fields(
      .id(),
      .field(purchase.name, is: .required, ofType: .string),
      .field(purchase.quantity, is: .required, ofType: .int),
      .field(purchase.unit_price, is: .required, ofType: .int)
    )
    }
}