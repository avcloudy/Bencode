public enum BencodeError: Error {
    //    case invalidBencodedString
    case invalidString
    case cantReadFile
    case indexOutOfBounds
    case unknownToken(_: UInt8)
    case tokenNotFound(_: UInt8)
    case invalidNumber
    case badKey
}
