import PackageDescription

let package = Package(
    name: "Cosmic",
	dependencies: [
		.Package(url: "https://github.com/IBM-Swift/BlueSocket", majorVersion: 0, minor: 12)
	]
)
