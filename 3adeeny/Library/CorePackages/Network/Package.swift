// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0")
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: ["NetworkKit"]
        )
    ],
    swiftLanguageModes: [.v6]
)
