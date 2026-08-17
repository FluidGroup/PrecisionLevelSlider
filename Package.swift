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
    .package(url: "https://github.com/FluidGroup/swiftui-Hosting", from: "3.0.0"),
  ],
  targets: [
    .target(
      name: "PrecisionLevelSlider",
      dependencies: [.product(name: "SwiftUIHosting", package: "swiftui-Hosting")]
    ),
  ]
)
