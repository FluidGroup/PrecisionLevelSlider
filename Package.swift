// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "PrecisionLevelSlider",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(name: "PrecisionLevelSlider", targets: ["PrecisionLevelSlider"]),
  ],
  dependencies: [
    .package(url: "https://github.com/FluidGroup/swiftui-Hosting", from: "2.0.0"),
  ],
  targets: [
    .target(
      name: "PrecisionLevelSlider",
      dependencies: [.product(name: "SwiftUIHosting", package: "swiftui-Hosting")]
    ),
  ]
)
