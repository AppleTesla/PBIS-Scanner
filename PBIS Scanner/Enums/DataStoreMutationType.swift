// MARK: Enums

enum DataStoreMutationType: String, CustomStringConvertible {
    case create = "create", delete = "delete", update = "update"
    
    var description: String {
        return self.rawValue
    }
}
