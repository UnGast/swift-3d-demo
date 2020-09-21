// swift-tools-version:5.3

import PackageDescription

let package = Package(

    name: "swift-3d-demo",

    products: [

        .executable(
            name: "Demo3DGameApp",
            targets: ["Demo3DGameApp"]),
    ],

    dependencies: [

        .package(name: "GraphicalSwift", path: "../swift-gui-demo-app"),
        .package(name: "GL", url: "https://github.com/UnGast/swift-opengl.git", .branch("master"))
    ],

    targets: [
       
        .target(
            name: "Demo3DGameApp",
            dependencies: ["GraphicalSwift", "GL"])
    ]
)
