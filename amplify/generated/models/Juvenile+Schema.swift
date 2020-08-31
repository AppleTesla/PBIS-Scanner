// swiftlint:disable all
import Amplify
import Foundation

extension Juvenile {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case first_name
    case last_name
    case points
    case event_id
    case active
    case queue
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let juvenile = Juvenile.keys
    
    model.pluralName = "Juveniles"
    
    model.fields(
      .id(),
      .field(juvenile.first_name, is: .required, ofType: .string),
      .field(juvenile.last_name, is: .required, ofType: .string),
      .field(juvenile.points, is: .required, ofType: .int),
      .field(juvenile.event_id, is: .required, ofType: .int),
      .field(juvenile.active, is: .required, ofType: .int),
      .belongsTo(juvenile.queue, is: .optional, ofType: Queue.self, targetName: "juvenileQueueId")
    )
    }
}