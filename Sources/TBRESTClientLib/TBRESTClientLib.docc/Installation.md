# Installation
This library can be added to your Xcode or SPM project.

## Adding to Xcode Project
When adding this library to your Xcode project use the build-in dependency management as shown below. As URL to the git repo use `https://bitbucket.org/swift-projects/tbrestclientlib.git`.


![Add package to Xcode project using native dependency management](addToXcode)

## Adding to SPM Project
When adding this library to your SPM project, make sure your `Package.swift` looks something like this:

```swift
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [.iOS(.v17),
                .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://bitbucket.org/swift-projects/tbrestclientlib.git", from: "0.0.8"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "MyApp",
            dependencies: [
                .product(name: "TBRESTClientLib", package: "TBRESTClientLib"),
            ],
            path: "Sources"),
    ]
)
```
