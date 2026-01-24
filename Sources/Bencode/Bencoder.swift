import Foundation

public struct Bencoder {
    private let zero = Character("0").asciiValue!
    private let nine = Character("9").asciiValue!
    private let i = Character("i").asciiValue!
    private let l = Character("l").asciiValue!
    private let d = Character("d").asciiValue!
    private let e = Character("e").asciiValue!
    private let colon = Character(":").asciiValue!

    public func decode(bencodedString string: String) throws -> Bencode {
        guard let data = string.data(using: .utf8) else {
            throw BencodeError.invalidString
        }
        return try decode(data: data)
    }

    public func decode(data: Data) throws -> Bencode {
        return try parse(data).bencode
    }

    public func decode(file url: URL) async throws -> Bencode {
        let data = try await Task.detached(priority: .userInitiated) {
            try Data(contentsOf: url)
        }.value
        return try decode(data: data)
    }
}

// MARK: - Private decoding helpers

extension Bencoder {

    fileprivate func parse(_ data: Data) throws -> (bencode: Bencode, index: Int) {
        return try parse(Array(data), from: 0)
    }

    fileprivate func parse(_ data: [UInt8], from index: Int) throws -> (
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

    fileprivate func parseString(data: [UInt8], index: Int) throws -> (bencode: Bencode, index: Int)
    {
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

    fileprivate func parseInt(data: [UInt8], index: Int) throws -> (bencode: Bencode, index: Int) {
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

    fileprivate func parseList(data: [UInt8], index: Int) throws -> (bencode: Bencode, index: Int) {
        var l: [Bencode] = []
        var currentIndex: Int = index

        while data[currentIndex] != e {
            let result = try parse(data, from: currentIndex)
            l.append(result.bencode)
            currentIndex = result.index
        }
        return (.list(l), currentIndex + 1)
    }

    fileprivate func parseDict(data: [UInt8], index: Int) throws -> (bencode: Bencode, index: Int) {
        var d: [Data: Bencode] = [:]
        var currentIndex: Int = index

        while data[currentIndex] != e {
            let keyResult = try parse(data, from: currentIndex)
            guard case .string(let keyData) = keyResult.bencode else {
                throw BencodeError.badKey
            }
            let valueResult = try parse(data, from: keyResult.index)
            currentIndex = valueResult.index
            d[keyData] = valueResult.bencode
        }
        return (.dict(d), currentIndex + 1)
    }

}
