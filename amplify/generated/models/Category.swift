// swiftlint:disable all
import Amplify
import Foundation

public enum Category: String, EnumPersistable {
  case safe = "SAFE"
  case responsible = "RESPONSIBLE"
  case considerate = "CONSIDERATE"
}