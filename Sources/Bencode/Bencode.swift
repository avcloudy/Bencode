import Foundation

public enum Bencode: Equatable {
    case string(Data)
    case int(Int)
    indirect case list([Bencode])
    indirect case dict([Data: Bencode])

    init(bencodedString string: String) throws {
        let bencode = try Bencoder().decode(bencodedString: string)
        self = bencode
    }
    
    // access Bencode list by Int index
    subscript(index: Int) -> Bencode? {
        guard case .list(let l) = self,
              index >= 0,
              index < l.count else { return nil }
        return l[index]
    }
    
    var encoded: Data? {
        let bencode = Bencoder().encoded(bencode: self)
        return bencode
    }
    
    // access Bencode dict by String key
    subscript(key: String) -> Bencode? {
        guard case .dict(let d) = self,
              let keyData = key.data(using: .utf8) else { return nil }
        return d[keyData]
    }
    
    // access Bencode dict by Data key - this isn't very useful for eg torrents
    // but dict keys being UInt8 value stream is technically in Bencode spec
    subscript(key: Data) -> Bencode? {
        guard case .dict(let d) = self else { return nil }
        return d[key]
    }
}

extension Data {
    var encoded: Data? {
        return Data("\(self.count):".utf8) + self
    }
}
