// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Cosmic",

  products: [
    .library(name: "Cosmic", targets: [ "Cosmic" ])
  ],

  dependencies: [
		.package(url: "https://github.com/Kitura/BlueSocket", from: "2.0.2")
	],

  targets: [
    .target(
      name: "Cosmic",
      dependencies: [
        "Socket"
      ]
    ),
    .testTarget(
      name: "CosmicTests",
      dependencies: [ "Cosmic" ]
    )
  ],

  swiftLanguageVersions: [ .v4, .v5 ]
)
