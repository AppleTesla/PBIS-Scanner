// swiftlint:disable all
import Amplify
import Foundation

extension Behavior {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case title
    case category
    case location
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let behavior = Behavior.keys
    
    model.pluralName = "Behaviors"
    
    model.fields(
      .id(),
      .field(behavior.title, is: .required, ofType: .string),
      .field(behavior.category, is: .required, ofType: .enum(type: Category.self)),
      .belongsTo(behavior.location, is: .required, ofType: Location.self, targetName: "behaviorLocationId")
    )
    }
}