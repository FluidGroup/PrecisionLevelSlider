// PrecisionLevelSlider.swift
//
// Copyright (c) 2016 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI
import SwiftUIHosting
import UIKit

open class PrecisionLevelSlider: UIControl {

  public struct ValueRange {

    public let range: ClosedRange<Double>
    public let transform: (Double) -> Double

    public init(
      range: ClosedRange<Double>,
      transform: @escaping (Double) -> Double
    ) {
      self.range = range
      self.transform = transform
    }

  }

  public struct Haptics {

    public enum Style {
      case selection
      case impact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat)
    }

    public let trigger: (Double) -> Style?

    public init(trigger: @escaping (Double) -> Style?) {
      self.trigger = trigger
    }

  }

  private final class Proxy: ObservableObject {
    @Published var value: Double = 0
  }

  private struct Provider<Content: View>: View {

    @ObservedObject var proxy: Proxy

    private let content: (Double) -> Content

    init(
      proxy: Proxy,
      @ViewBuilder content: @escaping (Double) -> Content
    ) {
      self.content = content
      self.proxy = proxy
    }

    var body: some View {
      content(proxy.value)
    }

  }

  var onChangeValue: (Double) -> Void = { _ in }

  private let haptics: Haptics?

  private lazy var lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

  private lazy var mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

  private lazy var heavyImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

  private lazy var softImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

  private lazy var rigidImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)

  private lazy var selectionFeedbackGenerator = UISelectionFeedbackGenerator()
  private var proxy: Proxy?

  /// default 0.0. this value will be pinned to min/max
  public var value: Double = 0 {
    didSet {

      if oldValue != value {
        proxy?.value = value
      }

      onChangeValue(value)

      guard !scrollView.isDecelerating && !scrollView.isTracking else {
        return
      }

      let offset = valueToOffset(value: value)

      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [.beginFromCurrentState, .allowUserInteraction],
        animations: {

          self.scrollView.setContentOffset(offset, animated: false)

        }
      ) { (finish) in
      }
    }
  }

  public var range: ValueRange

  open var isContinuous: Bool = true

  private let scrollView = UIScrollView()
  private let contentView = UIView()

  private let maskGradientLayer: CAGradientLayer = {

    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
      UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor,
    ]
    gradientLayer.locations = [0, 0.4, 0.6, 1]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0)

    return gradientLayer
  }()

  private let centerLevelView: UIView
  private let trackView: UIView

  // MARK: - Initializers

  public convenience init(
    range: ValueRange,
    haptics: Haptics?,
    @ViewBuilder centerLevel: @escaping (Double) -> some View,
    @ViewBuilder track: @escaping (Double) -> some View
  ) {

    let proxy = Proxy()

    self.init(
      range: range,
      haptics: haptics,
      centerLevelView: SwiftUIHostingView(content: {
        Provider(proxy: proxy) {
          centerLevel($0)
        }
      }),
      trackView: SwiftUIHostingView(content: {
        Provider(proxy: proxy) {
          track($0)
        }
      })
    )

    self.proxy = proxy

  }

  public init(
    range: ValueRange,
    haptics: Haptics? = nil,
    centerLevelView: UIView,
    trackView: UIView
  ) {

    self.centerLevelView = centerLevelView
    self.trackView = trackView
    self.range = range
    self.haptics = haptics

    super.init(frame: .zero)

    layer.mask = maskGradientLayer

    backgroundColor = UIColor.clear

    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self

    scrollView.frame = bounds
    scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    addSubview(scrollView)

    scrollView.addSubview(contentView)

    contentView.addSubview(trackView)
    trackView.frame = contentView.bounds
    trackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    addSubview(centerLevelView)
    centerLevelView.isUserInteractionEnabled = false
    centerLevelView.frame = bounds
    centerLevelView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  open override func layoutSubviews() {
    super.layoutSubviews()

    let offset = valueToOffset(value: value)
    scrollView.setContentOffset(offset, animated: false)

    maskGradientLayer.frame = bounds

    let contentSize = CGSize(
      width: bounds.width,
      height: bounds.height
    )

    contentView.frame.size = contentSize
    scrollView.contentSize = contentSize

    let inset = contentSize.width / 2 + (max(0, scrollView.bounds.width - contentSize.width) / 2)
    scrollView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
  }

  open override var intrinsicContentSize: CGSize {
    return CGSize(
      width: UIView.noIntrinsicMetric,
      height: UIView.noIntrinsicMetric
    )
  }

  open override func contentHuggingPriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
    switch axis {
    case .horizontal:
      return .defaultLow
    case .vertical:
      return .defaultHigh
    @unknown default:
      return .defaultLow
    }
  }

  fileprivate func offsetToValue() -> Double {

    let progress =
    (scrollView.contentOffset.x + scrollView.contentInset.left) / contentView.bounds.size.width
    let actualProgress = Double(min(max(0, progress), 1))
    let value = ((range.range.upperBound - range.range.lowerBound) * actualProgress) + range.range.lowerBound

    return range.transform(value)
  }

  fileprivate func valueToOffset(value: Double) -> CGPoint {

    let progress = (value - range.range.lowerBound) / (range.range.upperBound - range.range.lowerBound)
    let x = contentView.bounds.size.width * CGFloat(progress) - scrollView.contentInset.left
    return CGPoint(x: x, y: 0)
  }

}

extension PrecisionLevelSlider: UIScrollViewDelegate {

  public final func scrollViewDidScroll(_ scrollView: UIScrollView) {

    guard scrollView.bounds.width > 0 else {
      return
    }

    guard scrollView.isDecelerating || scrollView.isDragging else {
      return
    }

    if isContinuous {
      let oldValue = value
      value = offsetToValue()
      if oldValue != value {
        triggerHaptics()
        sendActions(for: .valueChanged)
      }
    }
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if isContinuous == false {
      let oldValue = value
      value = offsetToValue()
      if oldValue != value {
        triggerHaptics()
        sendActions(for: .valueChanged)
      }
    }
  }

  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
  {
    if decelerate == false && isContinuous == false {
      let oldValue = value
      value = offsetToValue()
      if oldValue != value {
        triggerHaptics()
        sendActions(for: .valueChanged)
      }
    }
  }

  private func triggerHaptics() {
    guard let style = haptics?.trigger(value) else {
      return
    }

    switch style {
    case .selection:
      selectionFeedbackGenerator.selectionChanged()
    case .impact(let style, let intensity):
      switch style {
      case .light:
        lightImpactFeedbackGenerator.impactOccurred(intensity: intensity)
      case .medium:
        mediumImpactFeedbackGenerator.impactOccurred(intensity: intensity)
      case .heavy:
        heavyImpactFeedbackGenerator.impactOccurred(intensity: intensity)
      case .soft:
        softImpactFeedbackGenerator.impactOccurred(intensity: intensity)
      case .rigid:
        rigidImpactFeedbackGenerator.impactOccurred(intensity: intensity)
      @unknown default:
        break
      }
    }

  }
}

@available(iOS 15, *)
public struct SwiftUIPrecisionLevelSlider<CenterLevel: View, Track: View>: UIViewRepresentable {

  @Binding var value: Double

  private let centerLevel: (Double) -> CenterLevel
  private let track: (Double) -> Track
  private let range: PrecisionLevelSlider.ValueRange
  private let haptics: PrecisionLevelSlider.Haptics?

  public init(
    value: Binding<Double>,
    haptics: PrecisionLevelSlider.Haptics?,
    range: PrecisionLevelSlider.ValueRange,
    @ViewBuilder centerLevel: @escaping (Double) -> CenterLevel,
    @ViewBuilder track: @escaping (Double) -> Track
  ) {
    self._value = value
    self.haptics = haptics
    self.centerLevel = centerLevel
    self.track = track
    self.range = range
  }

  public func makeUIView(context: Context) -> PrecisionLevelSlider {
    let view = PrecisionLevelSlider(
      range: range,
      haptics: haptics,
      centerLevel: centerLevel,
      track: track
    )

    view.tintColor = .systemRed
    view.onChangeValue = { value in
      // Prevent from modifying during view update warnings.
      Task { @MainActor in
        self.value = value
      }
    }
    return view
  }

  public func updateUIView(_ uiView: PrecisionLevelSlider, context: Context) {
    uiView.value = self.value
  }

}

//@available(iOS 17, *)#Preview("UIKit"){
//  PrecisionLevelSlider()
//}
