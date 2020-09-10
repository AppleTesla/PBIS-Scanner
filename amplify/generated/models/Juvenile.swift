// swiftlint:disable all
import Amplify
import Foundation

public struct Juvenile: Model {
  public let id: String
  public var first_name: String
  public var last_name: String
  public var points: Int
  public var event_id: Int
  public var active: Int
  public var isEnqueued: Bool
  
  public init(id: String = UUID().uuidString,
      first_name: String,
      last_name: String,
      points: Int,
      event_id: Int,
      active: Int,
      isEnqueued: Bool) {
      self.id = id
      self.first_name = first_name
      self.last_name = last_name
      self.points = points
      self.event_id = event_id
      self.active = active
      self.isEnqueued = isEnqueued
  }
}