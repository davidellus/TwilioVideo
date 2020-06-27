// swift-tools-version:5.2
import PackageDescription
import Foundation

// MARK: - Conveniences

let localDev = true
let devDir = "../"

struct Dep {
    let package: PackageDescription.Package.Dependency
    let targets: [Target.Dependency]
}

struct What {
    let dependency: Package.Dependency

    static func local(_ path: String) -> What {
        .init(dependency: .package(path: "\(devDir)\(path)"))
    }
    static func github(_ path: String, _ from: Version) -> What {
        .init(dependency: .package(url: "https://github.com/\(path)", from: from))
    }
    static func github(_ path: String, _ requirement: PackageDescription.Package.Dependency.Requirement) -> What {
        .init(dependency: .package(url: "https://github.com/\(path)", requirement))
    }
}

extension Array where Element == Dep {
    mutating func append(_ what: What, _ targets: Target.Dependency...) {
        append(.init(package: what.dependency, targets: targets))
    }
}

extension Target.Dependency {
    static func product(_ name: String, _ package: String? = nil) -> Target.Dependency {
        .product(name: name, package: package ?? name)
    }
}

// MARK: - Dependencies

var deps: [Dep] = []

deps.append(.github("vapor/vapor", "4.0.0"), .product("Vapor", "vapor"))
deps.append(.github("vapor/fluent", "4.0.0-rc"), .product("Fluent", "fluent"))
deps.append(.github("vapor/fluent-postgres-driver", "2.0.0"), .product("FluentPostgresDriver", "fluent-postgres-driver"))
deps.append(.github("vapor/jwt-kit", "4.0.0-rc.1.4"), .product("Fluent", "fluent"))

if localDev {
    deps.append(.local("TwilioPackage"), .product("TwilioPackage"))
} else {
    deps.append(.github("davidellus/TwilioPackage", "1.1.0"), .product("TwilioPackage"))
}

// MARK: - Package

let package = Package(
    name: "TwilioVideoApp",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: deps.map { $0.package },
    targets: [
        .target(name: "App", dependencies: deps.flatMap { $0.targets }),
        .target(name: "Run", dependencies: [
            .target(name: "App"),
        ]),
        .testTarget(name: "TwilioVideoAppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor")
        ])
    ]
)
