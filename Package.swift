// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "PrecisionLevelSlider",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(name: "PrecisionLevelSlider", targets: ["PrecisionLevelSlider"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "PrecisionLevelSlider"
    ),
  ]
)
