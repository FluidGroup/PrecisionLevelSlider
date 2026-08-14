// swift-tools-version:6.3
import PackageDescription

let package = Package(
  name: "PrecisionLevelSlider",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: "PrecisionLevelSlider", targets: ["PrecisionLevelSlider"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ntnmrndn/swiftui-Hosting", branch: "antoine/ios_17"),
  ],
  targets: [
    .target(
      name: "PrecisionLevelSlider",
      dependencies: [.product(name: "SwiftUIHosting", package: "swiftui-Hosting")]
    ),
  ]
)
