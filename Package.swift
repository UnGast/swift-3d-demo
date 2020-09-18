// swift-tools-version:5.3

import PackageDescription

let package = Package(

    name: "swift-3d-demo",

    products: [

        .executable(
            name: "DemoApp",
            targets: ["DemoApp"]),
    ],

    dependencies: [

        .package(name: "GraphicalSwift", url: "https://github.com/UnGast/swift-cross-platform-gui-example", .branch("master")),
        .package(name: "GL", url: "https://github.com/UnGast/swift-opengl.git", .branch("master"))
    ],

    targets: [
       
        .target(
            name: "DemoApp",
            dependencies: ["GraphicalSwift", "GL"])
    ]
)
