// swiftlint:disable all
import Amplify
import Foundation

extension Queue {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case juveniles
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let queue = Queue.keys
    
    model.pluralName = "Queues"
    
    model.fields(
      .id(),
      .hasMany(queue.juveniles, is: .optional, ofType: Juvenile.self, associatedWith: Juvenile.keys.queue)
    )
    }
}