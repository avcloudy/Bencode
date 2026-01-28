import Foundation
import Testing

@testable import Bencode

struct BencodeTests {
    // MARK: - Decode tests
    struct BencodeDecodeTestsFromString {
        @Test func decodeStringTrivial() throws {
            let testBencodedString = "1:a"
            let decodedString = try Bencode(bencodedString: testBencodedString)
            #expect(decodedString == .string("a".data(using: .utf8)!))
        }

        @Test func decodeStringTrivialData() throws {
            let testBencodedData = Data("1:a".utf8)
            let decodedData = try Bencode(data: testBencodedData)
            #expect(decodedData == .string(Data("a".utf8)))
        }

        @Test func decodeString() throws {
            let testBencodedString = "22:This is a simple test!"
            let decodedString = try Bencode(bencodedString: testBencodedString)
            #expect(decodedString == .string("This is a simple test!".data(using: .utf8)!))
        }

        @Test func decodeStringEndEarly() throws {
            let testBencodedString = "21:This is a simple test!"
            let decodedString = try Bencode(bencodedString: testBencodedString)
            #expect(decodedString == .string("This is a simple test".data(using: .utf8)!))
        }

        @Test func decodeIntZero() throws {
            let testBencodedString = "i0e"
            let decodedInt = try Bencode(bencodedString: testBencodedString)
            #expect(decodedInt == .int(0))
        }

        @Test func decodeInt() throws {
            let testBencodedString = "i42e"
            let decodedInt = try Bencode(bencodedString: testBencodedString)
            #expect(decodedInt == .int(42))
        }

        @Test func decodeEmptyList() throws {
            let testBencodedString = "le"
            let decodedList = try Bencode(bencodedString: testBencodedString)
            #expect(decodedList == .list([]))
        }

        @Test func decodeListTrivialString() throws {
            let testBencodedString = "l22:This is a simple test!e"
            let decodedList = try Bencode(bencodedString: testBencodedString)
            #expect(decodedList == .list([.string("This is a simple test!".data(using: .utf8)!)]))
        }

        @Test func decodeListTrivialStringAccessorIndex() throws {
            let testBencodedString = "l22:This is a simple test!e"
            let decodedList = try Bencode(bencodedString: testBencodedString)
            #expect(decodedList[0] == .string("This is a simple test!".data(using: .utf8)!))
        }

        @Test func decodeListTrivialInt() throws {
            let testBencodedString = "li42ee"
            let decodedList = try Bencode(bencodedString: testBencodedString)
            let manualList = Bencode.list([.int(42)])
            #expect(decodedList == manualList)
        }

        @Test func decodeRecursiveListTrivialString() throws {
            let testBencodedString = "ll22:This is a simple test!ee"
            let decodedList = try Bencode(bencodedString: testBencodedString)
            let manualList = Bencode.list([
                .list([.string("This is a simple test!".data(using: .utf8)!)])
            ])
            #expect(decodedList == manualList)
        }

        @Test func decodeEmptyDict() throws {
            let testBencodedString = "de"
            let decodedDict = try Bencode(bencodedString: testBencodedString)
            #expect(decodedDict == .dict([:]))
        }

        @Test func decodeTrivialDict() throws {
            let testBencodedString = "d3:Key5:Valuee"
            let decodedDict = try Bencode(bencodedString: testBencodedString)
            let key = "Key".data(using: .utf8)!
            let value = Bencode.string("Value".data(using: .utf8)!)
            #expect(decodedDict == .dict([key: value]))
        }

        @Test func decodeTrivialDictAccessorString() throws {
            let testBencodedString = "d3:Key5:Valuee"
            let decodedDict = try Bencode(bencodedString: testBencodedString)
            #expect(decodedDict["Key"] == .string("Value".data(using: .utf8)!))
        }

        @Test func decodeTrivialDictAccessorData() throws {
            let testBencodedString = "d3:Key5:Valuee"
            let decodedDict = try Bencode(bencodedString: testBencodedString)
            let key = "Key".data(using: .utf8)!
            #expect(decodedDict[key] == .string("Value".data(using: .utf8)!))
        }

        @Test func decodeTrivialDictInt() throws {
            let testBencodedString = "d3:Keyi42ee"
            let decodedDict = try Bencode(bencodedString: testBencodedString)
            let key = "Key".data(using: .utf8)!
            let value = Bencode.int(42)
            #expect(decodedDict == .dict([key: value]))
        }

        @Test func decodeTrivialDictList() throws {
            let testBencodedString = "d3:Keyl3:one3:two5:threeee"
            let decodedDict = try Bencode(bencodedString: testBencodedString)
            let key = "Key".data(using: .utf8)!
            let one = Bencode.string("one".data(using: .utf8)!)
            let two = Bencode.string("two".data(using: .utf8)!)
            let three = Bencode.string("three".data(using: .utf8)!)
            let value = Bencode.list([one, two, three])
            #expect(decodedDict == .dict([key: value]))
        }

        @Test func decodeRecursiveDict() throws {
            let testBencodedString =
                "d4:dictd3:key5:valuee3:inti42e4:listl22:This is a simple test!i42ee6:string22:This is a simple test!e"
            let decodedDict = try Bencode(bencodedString: testBencodedString)
            let string = Bencode.string("This is a simple test!".data(using: .utf8)!)
            let int = Bencode.int(42)
            let list = Bencode.list([string, int])
            let key = "key".data(using: .utf8)!
            let value = Bencode.string("value".data(using: .utf8)!)
            let dict = Bencode.dict([key: value])
            let recursiveDict: [Data: Bencode] = [
                "dict".data(using: .utf8)!: dict,
                "int".data(using: .utf8)!: int,
                "list".data(using: .utf8)!: list,
                "string".data(using: .utf8)!: string,
            ]
            let bencodedRecursiveDict = Bencode.dict(recursiveDict)

            #expect(decodedDict["dict"] == bencodedRecursiveDict["dict"])
            #expect(decodedDict["int"] == bencodedRecursiveDict["int"])
            #expect(decodedDict["list"] == bencodedRecursiveDict["list"])
            #expect(decodedDict["string"] == bencodedRecursiveDict["string"])
        }
    }
    // MARK: - Error Tests
    struct BencodeErrorTests {
        @Test func indexOutOfBounds() throws {
            let bencodedList = "li41ei42e"
            #expect(throws: BencodeError.indexOutOfBounds) {
                let _ = try Bencode(bencodedString: bencodedList)
            }
        }

        @Test func unknownToken() throws {
            let bencodedList = "li41ek42ee"
            #expect(throws: BencodeError.unknownToken(Character("k").asciiValue!)) {
                let _ = try Bencode(bencodedString: bencodedList)
            }
        }

        @Test func invalidNumber() throws {
            let bencodedInt = "ifortytwoe"
            #expect(throws: BencodeError.invalidNumber) {
                let _ = try Bencode(bencodedString: bencodedInt)
            }
        }

        @Test func badKey() throws {
            let bencodedDict = "di42e5:value"
            #expect(throws: BencodeError.badKey) {
                let _ = try Bencode(bencodedString: bencodedDict)
            }
        }
    }
    // MARK: - Encode Tests
    struct BencodeEncodeFromBencodeObjects {
        @Test func encodeString() throws {
            let testBencodedString = Bencode.string("This is a simple test!".data(using: .utf8)!)
            #expect(testBencodedString.encoded == Data("22:This is a simple test!".utf8))
        }

        @Test func encodeInt() throws {
            let testBencodedString = Bencode.int(42)
            #expect(testBencodedString.encoded == Data("i42e".utf8))
        }

        @Test func encodeList() throws {
            let one = Bencode.string("one".data(using: .utf8)!)
            let two = Bencode.string("two".data(using: .utf8)!)
            let three = Bencode.string("three".data(using: .utf8)!)
            let testBencodedList = Bencode.list([one, two, three])
            #expect(testBencodedList.encoded == Data("l3:one3:two5:threee".utf8))
        }

        @Test func encodeDict() throws {
            let key = "key".data(using: .utf8)!
            let value = Bencode.string("value".data(using: .utf8)!)
            let aaaron = "aaaron".data(using: .utf8)!
            let done = Bencode.string("fucked up".data(using: .utf8)!)
            let testBencodedDict = Bencode.dict([key: value, aaaron: done])
            #expect(testBencodedDict.encoded == Data("d6:aaaron9:fucked up3:key5:valuee".utf8))
        }

        @Test func encodeDictConstructionMatchString() throws {
            let bencode = "d6:aaaron9:fucked up3:key5:valuee"
            let dict = try Bencode(bencodedString: bencode)
            #expect(dict.encoded == bencode.data(using: .utf8))
        }
    }
    // MARK: - Torrent Read Tests
    struct BencodeTorrentReadTests {
        @Test func debianReadTest() async throws {
            //            guard
            //                let url = Bundle.module.url(
            //                    forResource: "debian-13.3.0-amd64-DVD-1.iso", withExtension: "torrent")
            //            else {
            //                fatalError()
            //            }
            let url = try #require(
                Bundle.module.url(
                    forResource: "debian-13.3.0-amd64-DVD-1.iso", withExtension: "torrent"))
            let metadata = try await Bencode(file: url)
            let announce = metadata["announce"]
            let announceExpected = Bencode.string(
                "http://bttracker.debian.org:6969/announce".data(using: .utf8)!)
            #expect(announce == announceExpected)
            let comment = metadata["comment"]
            let commentExpected = Bencode.string(
                "Debian CD from cdimage.debian.org".data(using: .utf8)!)
            #expect(comment == commentExpected)
            let createdBy = metadata["created by"]
            let createdByExpected = Bencode.string("mktorrent 1.1".data(using: .utf8)!)
            #expect(createdBy == createdByExpected)
            let creationDate = metadata["creation date"]
            let creationDateExpected = Bencode.int(1_768_050_341)
            #expect(creationDate == creationDateExpected)
            let info = try #require(metadata["info"])
            let length = info["length"]
            let lengthExpected = Bencode.int(3_925_868_544)
            #expect(length == lengthExpected)
            let name = info["name"]
            let nameExpected = Bencode.string("debian-13.3.0-amd64-DVD-1.iso".data(using: .utf8)!)
            #expect(name == nameExpected)
            let pieceLength = info["piece length"]
            let pieceLengthExpected = Bencode.int(262144)
            #expect(pieceLength == pieceLengthExpected)
            let urlList = metadata["url-list"]
            let urlListExpected = Bencode.list(
                [
                    .string(
                        "https://cdimage.debian.org/cdimage/release/13.3.0/amd64/iso-dvd/debian-13.3.0-amd64-DVD-1.iso"
                            .data(using: .utf8)!),
                    .string(
                        "https://cdimage.debian.org/cdimage/archive/13.3.0/amd64/iso-dvd/debian-13.3.0-amd64-DVD-1.iso"
                            .data(using: .utf8)!),
                ]
            )
            #expect(urlList == urlListExpected)
            let hash = info.hexHashed
            let hashExpected = "c6ee205099093bbe2dffa4e1b2794b7dae0e6046"
            #expect(hash == hashExpected)
        }

        @Test func fedoraReadTest() async throws {
            let url = try #require(
                Bundle.module.url(
                    forResource: "Fedora-Workstation-Live-aarch64-43", withExtension: "torrent"))
            let metadata = try await Bencode(file: url)
            let announce = metadata["announce"]
            let announceExpected = Bencode.string(
                "http://torrent.fedoraproject.org:6969/announce".data(using: .utf8)!)
            #expect(announce == announceExpected)
            let createdBy = metadata["created by"]
            let createdByExpected = Bencode.string("mktorrent 1.1".data(using: .utf8)!)
            #expect(createdBy == createdByExpected)
            let creationDate = metadata["creation date"]
            let creationDateExpected = Bencode.int(1_761_757_966)
            #expect(creationDate == creationDateExpected)
            let info = try #require(metadata["info"])
            let files = try #require(info["files"])
            let fileszero = files[0]
            let filesone = files[1]
            let fileszeroExpected = Bencode.dict([
                "length".data(using: .utf8)!: .int(1064),
                "path".data(using: .utf8)!: .list([
                    .string("Fedora-Workstation-43-1.6-aarch64-CHECKSUM".data(using: .utf8)!)
                ]),
            ])
            let filesoneExpected = Bencode.dict([
                "length".data(using: .utf8)!: .int(2_566_119_424),
                "path".data(using: .utf8)!: .list([
                    .string("Fedora-Workstation-Live-43-1.6.aarch64.iso".data(using: .utf8)!)
                ]),
            ])
            #expect(fileszero == fileszeroExpected)
            #expect(filesone == filesoneExpected)
            let name = info["name"]
            let nameExpected = Bencode.string(
                "Fedora-Workstation-Live-aarch64-43".data(using: .utf8)!)
            #expect(name == nameExpected)
            let pieceLength = info["piece length"]
            let pieceLengthExpected = Bencode.int(262144)
            #expect(pieceLength == pieceLengthExpected)
            let hash = info.hexHashed
            let hashExpected = "c1c7a122a6232d74abea8c49d22da752cfc7f25c"
            #expect(hash == hashExpected)
        }
    }
}
