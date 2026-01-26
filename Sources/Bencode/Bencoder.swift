import Foundation

public struct Bencoder {
    private static let zero = Character("0").asciiValue!
    private static let nine = Character("9").asciiValue!
    private static let i = Character("i").asciiValue!
    private static let l = Character("l").asciiValue!
    private static let d = Character("d").asciiValue!
    private static let e = Character("e").asciiValue!
    private static let colon = Character(":").asciiValue!

    /// Decode Bencode from a String
    /// - Parameter string: String fitting the Bencode specification:
    ///    string: "This is a string!" <-> "17.This is a string!"
    ///    int: 42 <-> "i42e"
    ///    list: ["one", "two", "three"] <-> "l3:one3:two5:threee"
    ///    dict: ["key": "value"] <-> "d3:key5:valuee"
    /// - Returns: Bencode enum object
    /// Preferred usage is through Bencode initialiser, so instead of Bencoder.decode(bencodedString:) use Bencode(bencodedString:)
    public static func decode(bencodedString string: String) throws(BencodeError) -> Bencode {
        let data = Data(string.utf8)
        return try decode(data: data)
    }

    /// As for decode(bencodedString:) but with Data instead of String
    ///  - Parameter data: Data fitting the Bencode specification
    ///  - Returns: Bencode enum object
    ///  Use Bencode(data:) as for decode(bencodedString:)
    public static func decode(data: Data) throws(BencodeError) -> Bencode {
        return try parse(data).bencode
    }

    /// Decode Bencode from a file
    /// - Parameter url: path to .torrent file.
    /// - Returns: Bencode enum object
    /// Use Bencode(file:) as for decode(bencodedString)
    public static func decode(file url: URL) async throws -> Bencode {
        let data = try await Task.detached(priority: .userInitiated) {
            try Data(contentsOf: url)
        }.value
        return try decode(data: data)
    }

    /// Encode a Bencode object into a stream of bytes conforming to Bencode specification
    /// - Parameter bencode: Any Bencode enum
    /// - Returns: Data object with encoded Bencode bytes
    /// Access through bencode.encoded
    public static func encoded(bencode: Bencode) -> Data {
        switch bencode {
        case .string(let d): return Data("\(d.count):".utf8) + d
        case .int(let i): return Data("i\(i)e".utf8)
        case .list(let l):
            let body = l.map { encoded(bencode: $0) }
                .reduce(Data(), +)
            return Data("l".utf8) + body + Data("e".utf8)
        case .dict(let d):
            let body =
                d
                .sorted { $0.key.lexicographicallyPrecedes($1.key) }
                .map { (key, value) in
                    key.encoded! + value.encoded!
                }
                .reduce(Data(), +)
            return Data("d".utf8) + body + Data("e".utf8)
        }
    }
}

// MARK: - Private decoding helpers

extension Bencoder {

    private static func parse(_ data: Data) throws(BencodeError) -> (bencode: Bencode, index: Int) {
        return try parse(data, from: 0)
    }

    private static func parse(_ data: Data, from index: Int) throws(BencodeError) -> (
        bencode: Bencode, index: Int
    ) {
        guard data.endIndex >= index + 1 else {
            throw BencodeError.indexOutOfBounds
        }
        let nextIndex = index + 1

        let byte = data[index]
        switch byte {
        case zero...nine: return try parseString(data: data, index: index)
        case i: return try parseInt(data: data, index: nextIndex)
        case l: return try parseList(data: data, index: nextIndex)
        case d: return try parseDict(data: data, index: nextIndex)
        default: throw BencodeError.unknownToken(data[index])
        }
    }

    private static func parseString(data: Data, index: Int) throws(BencodeError) -> (
        bencode: Bencode, index: Int
    ) {
        guard let sep = data[index...].firstIndex(of: colon) else {
            throw BencodeError.tokenNotFound(colon)
        }
        guard let lengthString = String(bytes: data[index..<sep], encoding: .ascii),
            let length = Int(lengthString)
        else {
            throw BencodeError.invalidNumber
        }
        let start = sep + 1
        let end = start + length
        return (.string(Data(data[start..<end])), end)
    }

    private static func parseInt(data: Data, index: Int) throws(BencodeError) -> (
        bencode: Bencode, index: Int
    ) {
        guard let end = data[index...].firstIndex(of: e) else {
            throw BencodeError.tokenNotFound(e)
        }
        guard let intString = String(bytes: data[index..<end], encoding: .ascii),
            let int = Int(intString)
        else {
            throw BencodeError.invalidNumber
        }
        return (.int(int), end + 1)
    }

    private static func parseList(data: Data, index: Int) throws(BencodeError) -> (
        bencode: Bencode, index: Int
    ) {
        var l: [Bencode] = []
        var currentIndex: Int = index

        while data.endIndex > currentIndex,
            data[currentIndex] != e
        {
            let result = try parse(data, from: currentIndex)
            l.append(result.bencode)
            currentIndex = result.index
        }
        guard data.endIndex > currentIndex else {
            throw BencodeError.indexOutOfBounds
        }
        return (.list(l), currentIndex + 1)
    }

    private static func parseDict(data: Data, index: Int) throws(BencodeError) -> (
        bencode: Bencode, index: Int
    ) {
        var d: [Data: Bencode] = [:]
        var currentIndex: Int = index

        while data.endIndex > currentIndex,
            data[currentIndex] != e
        {
            let keyResult = try parse(data, from: currentIndex)
            guard case .string(let keyData) = keyResult.bencode else {
                throw BencodeError.badKey
            }
            let valueResult = try parse(data, from: keyResult.index)
            currentIndex = valueResult.index
            d[keyData] = valueResult.bencode
        }
        guard data.endIndex > currentIndex else {
            throw BencodeError.indexOutOfBounds
        }
        return (.dict(d), currentIndex + 1)
    }

    // TODO: Think about implementing parsers as black box iterator
    // Pass in Data object and call nextByte in loop. Wrapper contains counter and signals
    // when object is exhausted.
}
