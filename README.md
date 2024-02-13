# PrecisionLevelSlider

A slider that allows the user to select a value with a high level of precision.
Not grabbing knobs but sliding reels.

<p align="center">
  <img src="example.gif" width=375>
</p>

## Usage

### SwiftUI

```swift
SwiftUIPrecisionLevelSlider(
    value: $value,
    haptics: .init(trigger: { value in
        // trigger haptics according to the value
    }),
    range: .init(range: -45...45, transform: { $0.rounded(.toNearestOrEven) }),
    centerLevel: { value in
        // your custom view here
    },
    track: { value in
        // your custom view here
    }
)
.tint(.primary)
.frame(height: 50)
```

### UIKit

Use `PrecisionLevelSlider`
