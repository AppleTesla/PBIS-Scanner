// MARK: Enums

enum ResponseError: Error {
    case requestProblem
    case tokenProblem
    case networkProblem
    case responseProblem(Error)
    case decodingProblem(Error)
    case otherProblem(Error)
    case deferred
}
