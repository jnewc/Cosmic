import PackageDescription

let package = Package(
    name: "Cosmic",
	dependencies: [
		.Package(url: "https://github.com/IBM-Swift/BlueSocket", majorVersion: 1, minor: 0)
	]
)
