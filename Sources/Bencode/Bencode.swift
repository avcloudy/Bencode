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

    subscript(key: String) -> Bencode? {
        if case .dict(let dict) = self,
            let keyData = key.data(using: .utf8)
        {
            return dict[keyData]
        }
        return nil
    }
}
