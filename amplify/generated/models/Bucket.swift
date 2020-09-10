// swiftlint:disable all
import Amplify
import Foundation

public struct Bucket: Model {
  public let id: String
  public var posts: List<Post>?
  
  public init(id: String = UUID().uuidString,
      posts: List<Post> = []) {
      self.id = id
      self.posts = posts
  }
}