//
//  ContentView.swift
//  Development
//
//  Created by Muukii on 2024/02/13.
//

import SwiftUI
import PrecisionLevelSlider

struct ContentView: View {
  var body: some View {
    DemoContent()
  }
}

struct ShortBar: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 8)
      .frame(width: 1, height: 10)
  }
}

@available(iOS 15, *)
private struct DemoContent: View {

  @State var value: Double = 0
  @State var isDragging: Bool = false

  var body: some View {
    VStack {
      HStack {
        Circle()
          .frame(width: 8, height: 8)
          .foregroundStyle(isDragging ? Color.green : Color.gray)
        Text("\(value)").monospacedDigit()
      }
      SwiftUIPrecisionLevelSlider(
        value: $value,
        haptics: .init(trigger: { value in
          if value.truncatingRemainder(dividingBy: 5) == 0 {
            return .impact(style: .light, intensity: 0.4)
          }
          return nil
        }),
        range: .init(range: -45...45, transform: { $0.rounded(.toNearestOrEven) }),
        draggingHandler: { value in
          isDragging = value
        },
        centerLevel: { value, isDragging in
          HStack {
            Spacer()
            VStack {
              Rectangle()
                .frame(width: 1)
              Spacer()
            }
            Spacer()
          }
          .foregroundStyle(.tint)
        },
        track: { value, isDragging in
          VStack {
            HStack {
              Spacer()
              Circle()
                .frame(width: 6, height: 6)
                .opacity(value == 0 ? 0 : 1)
                .animation(.spring, value: value == 0)
              Spacer()
            }
            HStack(spacing: 0) {
              ForEach(0..<8) { i in
                ShortBar()
                  .foregroundStyle(.primary)
                Group {
                  Spacer(minLength: 0)
                  ShortBar()
                  Spacer(minLength: 0)
                  ShortBar()
                  Spacer(minLength: 0)
                  ShortBar()
                  Spacer(minLength: 0)
                  ShortBar()
                  Spacer(minLength: 0)
                }
                .foregroundStyle(.secondary)
              }
              ShortBar()
                .foregroundStyle(.primary)
            }
          }
          .foregroundStyle(.tint)
        }
      )
      .tint(.primary)
      .frame(height: 50)

      HStack {
        Button("0") {
          value = 0
        }
        Button("0.5") {
          value = 0.5
        }
        Button("1") {
          value = 1
        }
      }
    }

  }
}

@available(iOS 15, *)#Preview(
  "SwiftUI",
  body: {
    DemoContent()
  }
)

#Preview {
  ContentView()
}
