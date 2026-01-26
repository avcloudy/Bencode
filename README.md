# Bencode
*version 1.0.0*
***

A Swift Bencode encoder/decoder library intended for use with native macOS torrent clients or \*nix trackers, written in async Swift 6.

Inspired by the very excellent [danieltmbr/Bencode](https://github.com/danieltmbr/Bencode).


## Prerequisites

* Swift 6.2
* Xcode 26

## Installation

### Swift Package Manager

Add dependency to your Package.swift Package declaration e.g.: 

```swift
dependencies: [
    .package(url: "https://github.com/avcloudy/Bencode.git", from: "1.0.0")
],
```

Add it as a target to the specific target/s:

```swift
targets: [
        .target(
            name: "Bencode"
            dependencies: [
                .product(name: "Bencode", package: "Bencode")
            ]
        ),
    ...
```

Build your package or run `swift package resolve`.

### Xcode

In Xcode go to File > Add Package Dependencies and enter the url of this repository (https://github.com/avcloudy/Bencode.git).

## Usage

import Bencode at the top of every file where you use it.

### Initialise a Bencode object from a file:

```swift
let url = URL(fileURLWithPath: "path/to/file.torrent")
let bencode: Bencode? = try await Bencode(file: url)
```

### Initialise a Bencode object from a string:

```swift
let string = "17:This is a string!"
let bencode: Bencode? = try Bencode(bencodedString: string)
```

### Initialise a Bencode object from a stream of bytes:

```swift
let bytes = "17:This is a string!".data(using: .utf8)
let bencode: Bencode? = try Bencode(data: bytes)
```

### Access parts of Bencode objects

```swift
let announceList = metadata["announce-list"]
let firstAnnounce = announceList?[0]
```

### Hash a Bencode object:

```swift
guard let infoDict = bencode["info"] else { Error }
let hash: String = infoDict.hexHashed
```

### Build manual Bencode objects

```swift
let one = Bencode.string("One".data(using: .utf8)
let two = Bencode.int(2)
let three = Bencode.list(.string(one, two))
let dict = Bencode.dict([
    "string".data(using: .utf8): one,
    "int".data(using: .utf8): two
    "list".data(using: .utf8): three
])
```

### Build a bencoded stream of bytes from a Bencode object:
```swift
let bytes: Data = bencode.encoded
```

## Help

* Post issues or contact me directly
* Feel free to request features!

## License
Licensed under the MIT License, see LICENSE for more details.
