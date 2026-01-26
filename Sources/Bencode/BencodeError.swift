public enum BencodeError: Error, Equatable {
    case indexOutOfBounds
    case unknownToken(_: UInt8)
    case tokenNotFound(_: UInt8)
    case invalidNumber
    case badKey
}
