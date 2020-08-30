// MARK: Enums

enum DataStoreMutationType: String, CustomStringConvertible {
    case create = "create", delete = "delete"
    
    var description: String {
        return self.rawValue
    }
}
