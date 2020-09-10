// MARK: Enums

enum Badge: Hashable {
    case Juvenile(Origin?)

    enum Origin {
        case online, offline
    }

    var image: SystemImage {
        switch self {
        case .Juvenile(.online):
            return .checkmarkCircleFill
        case .Juvenile(.offline):
            return .xmarkCircleFill
        case .Juvenile(.none):
            return .questionmarkCircleFill
        }
    }
}
