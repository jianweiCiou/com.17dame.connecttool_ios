// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConnectTool",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "cxxLibrary",
            targets: ["cxxLibrary"]),
        .library(
            name: "ConnectTool",
            targets: ["ObjCConnectTool","ConnectTool"]
        ),
    ],
    dependencies: [ 
    ],
    targets: [
        .target(
            name: "cxxLibrary"),
        .target(
            name: "ObjCConnectTool",
            dependencies: ["cxxLibrary" ],
            path: "Sources/ObjC",
            cxxSettings: [
                .headerSearchPath("../CPP/")
            ]
        ),
        .target(
            name: "ConnectTool",
            dependencies: ["ObjCConnectTool" ,"cxxLibrary" ],
            path: "Sources/Swift"
        ),
    ]
)
