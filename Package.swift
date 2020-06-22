// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "TwilioVideo",
    platforms: [
       .macOS(.v10_15)
    ],
   products: [
   // Products define the executables and libraries produced by a package, and make them visible to other packages.
    
   ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit", from: "4.0.0-rc.1.4"),
//        .package(path: "/Users/davidepedro/Desktop/server/Vapor/TwilioPackage")
        .package(url: "https://github.com/davidellus/TwilioPackage", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                ._productItem(name: "JWTKit", package: "jwt-kit"),
                .product(name: "TwilioPackage", package: "TwilioPackage")
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
