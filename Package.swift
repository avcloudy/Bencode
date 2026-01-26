// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bencode",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Bencode",
            targets: ["Bencode"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Bencode"
        ),
        .testTarget(
            name: "BencodeTests",
            dependencies: ["Bencode"],
            resources: [
                .copy("Resources/debian-13.3.0-amd64-DVD-1.iso.torrent")
                //                .copy("Resources/Fedora-Budgie-Live-x86_64-43.torrent"),
                //                .copy("Resources/Fedora-Cinnamon-Live-x86_64-43.torrent"),
                //                .copy("Resources/Fedora-Workstation-Live-aarch64-43.torrent"),
                //                .copy("Resources/ubuntu-25.10-desktop-amd64.iso.torrent"),
                //                .copy("Resources/ubuntu-25.10-live-server-amd64.iso.torrent")
            ]
        ),
    ]
)
