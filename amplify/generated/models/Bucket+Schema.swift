// swiftlint:disable all
import Amplify
import Foundation

extension Bucket {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case posts
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let bucket = Bucket.keys
    
    model.pluralName = "Buckets"
    
    model.fields(
      .id(),
      .hasMany(bucket.posts, is: .optional, ofType: Post.self, associatedWith: Post.keys.bucket)
    )
    }
}