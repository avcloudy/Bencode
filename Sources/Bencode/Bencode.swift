import CryptoKit
import Foundation

public enum Bencode: Equatable {
    case string(Data)
    case int(Int)
    indirect case list([Bencode])
    indirect case dict([Data: Bencode])

    // MARK: Bencode Initialisers
    /// Decode Bencode from a String
    /// - Parameter string: String fitting the Bencode specification:
    ///    string: "This is a string!" <-> "17.This is a string!"
    ///    int: 42 <-> "i42e"
    ///    list: ["one", "two", "three"] <-> "l3:one3:two5:threee"
    ///    dict: ["key": "value"] <-> "d3:key5:valuee"
    /// - Returns: Bencode enum object
    init(bencodedString string: String) throws {
        let bencode = try Bencoder.decode(bencodedString: string)
        self = bencode
    }

    /// Decode Bencode from a file
    /// - Parameter url: Path to the .torrent file containing Bencode specification values:
    ///    string: "This is a string!" <-> "17.This is a string!"
    ///    int: 42 <-> "i42e"
    ///    list: ["one", "two", "three"] <-> "l3:one3:two5:threee"
    ///    dict: ["key": "value"] <-> "d3:key5:valuee"
    /// - Returns: Bencode enum object
    init(file url: URL) async throws {
        let bencode = try await Bencoder.decode(file: url)
        self = bencode
    }

    /// Decode Bencode from a Data object
    /// - Parameter data: Data fitting the Bencode specification:
    ///    string: "This is a string!" <-> "17.This is a string!"
    ///    int: 42 <-> "i42e"
    ///    list: ["one", "two", "three"] <-> "l3:one3:two5:threee"
    ///    dict: ["key": "value"] <-> "d3:key5:valuee"
    /// - Returns: Bencode enum object
    init(data: Data) throws {
        let bencode = try Bencoder.decode(data: data)
        self = bencode
    }

    // MARK: Bencode accessors
    // access Bencode list by Int index
    subscript(index: Int) -> Bencode? {
        guard case .list(let l) = self,
            index >= 0,
            index < l.count
        else { return nil }
        return l[index]
    }

    // access Bencode dict by String key
    subscript(key: String) -> Bencode? {
        guard case .dict(let d) = self
        else { return nil }
        let keyData = Data(key.utf8)
        return d[keyData]
    }

    // access Bencode dict by Data key - this isn't very useful for eg torrents
    // but dict keys being UInt8 value stream is technically in Bencode spec
    subscript(key: Data) -> Bencode? {
        guard case .dict(let d) = self else { return nil }
        return d[key]
    }

    // access encoded representation of Bencode object
    var encoded: Data? {
        let bencode = Bencoder.encoded(bencode: self)
        return bencode
    }

    // The raw bytes of the hash
    var hashed: Data? {
        guard let bencode = self.encoded else { return nil }
        return Data(Insecure.SHA1.hash(data: bencode))
    }

    // The raw bytes of the hash in hex format string
    var hexHashed: String? {
        guard let bencode = self.encoded else { return nil }
        let hexHash = Insecure.SHA1.hash(data: bencode)
            .map { String(format: "%02x", $0) }
            .joined()
        return hexHash
    }
}

// to enable use of Data objects as key in Dict without having to make a wrapper around it
extension Data {
    var encoded: Data? {
        return Data("\(self.count):".utf8) + self
    }
}
