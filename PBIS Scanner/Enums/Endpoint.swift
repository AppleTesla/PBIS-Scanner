// MARK: Enums

enum Endpoint {
    case juvenile(J)
    case location
    case reward
    case behavior

    enum J {
        case incr, get, transactions, activate, deactivate, create, delete
    }

    var endpoint: String {
        switch self {
        case .behavior:
            return "/fetch/behaviors"
        case .location:
            return "/fetch/locations"
        case .reward:
            return "/fetch/rewards"
        case .juvenile(.get):
            return "/fetch/juveniles"
        case .juvenile(.incr):
            return "/points/incr"
        case .juvenile(.transactions):
            return "/fetch/transactions"
        case .juvenile(.activate):
            return "/juvenile/activate"
        case .juvenile(.deactivate):
            return "/juvenile/deactivate"
        case .juvenile(.create):
            return "/juvenile/create"
        case .juvenile(.delete):
            return "/juvenile/delete"
        }
    }
}
