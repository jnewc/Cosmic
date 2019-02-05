// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Cosmic",
	dependencies: [
		.package(url: "https://github.com/IBM-Swift/BlueSocket", from: "1.0.0")
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
  swiftLanguageVersions: [.v4_2]
)
