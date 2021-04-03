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

import UIKit

open class PrecisionLevelSlider: UIControl {

  // MARK: - Properties

  open var longNotchColor: UIColor = .black {
    didSet {
      update()
    }
  }

  open var shortNotchColor: UIColor = UIColor(white: 0.2, alpha: 1) {
    didSet {
      update()
    }
  }

  open var centerNotchColor: UIColor = UIColor.orange {
    didSet {
      update()
    }
  }

  /// default 0.0. this value will be pinned to min/max
  @objc open dynamic var value: Float = 0 {
    didSet {

      guard !scrollView.isDecelerating && !scrollView.isDragging else {
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

  /// default 0.0. the current value may change if outside new min value
  @objc open dynamic var minimumValue: Float = 0 {
    didSet {
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

  /// default 1.0. the current value may change if outside new max value
  @objc open dynamic var maximumValue: Float = 1 {
    didSet {
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

  open var isContinuous: Bool = true

  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let notchLayers: [CALayer] = {
    return (0..<31).map { _ -> CALayer in
      CALayer()
    }
  }()
  private let centerNotchLayer = CALayer()

  private let gradientLayer: CAGradientLayer = {

    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
      UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor,
    ]
    gradientLayer.locations = [0, 0.4, 0.6, 1]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0)

    return gradientLayer
  }()

  // MARK: - Initializers

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  // MARK: - Functions

  open override func layoutSubviews() {
    super.layoutSubviews()
    update()
  }

  open override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: 50)
  }

  func update() {

    let offset = valueToOffset(value: value)
    scrollView.setContentOffset(offset, animated: false)

    gradientLayer.frame = bounds
    let notchWidth: CGFloat = 1

    let interval = floor((bounds.size.width) / CGFloat(notchLayers.count))

    let longNotchHeight: CGFloat = 14
    let shortNotchHeight: CGFloat = 8
    let offsetY = bounds.height / 2

    notchLayers.enumerated().forEach { i, l in

      let x: CGFloat = CGFloat(i) * interval

      if i % 5 == 0 {
        l.backgroundColor = longNotchColor.cgColor

        l.frame = CGRect(
          x: x,
          y: offsetY - (longNotchHeight / 2),
          width: notchWidth,
          height: longNotchHeight
        )

      } else {
        l.backgroundColor = shortNotchColor.cgColor
        l.frame = CGRect(
          x: x,
          y: offsetY - (shortNotchHeight / 2),
          width: notchWidth,
          height: shortNotchHeight
        )
      }
    }

    centerNotchLayer.backgroundColor = centerNotchColor.cgColor
    centerNotchLayer.frame = CGRect(x: bounds.midX, y: 0, width: notchWidth, height: bounds.height)

    let contentSize = CGSize(
      width: notchLayers.last!.frame.maxX - notchWidth,
      height: bounds.height
    )

    contentView.frame.size = contentSize
    scrollView.contentSize = contentSize

    let inset = contentSize.width / 2 + (max(0, scrollView.bounds.width - contentSize.width) / 2)
    scrollView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

  }

  func setup() {

    layer.mask = gradientLayer

    backgroundColor = UIColor.clear

    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self

    scrollView.frame = bounds
    scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(scrollView)
    scrollView.addSubview(contentView)
    notchLayers.forEach { contentView.layer.addSublayer($0) }
    layer.addSublayer(centerNotchLayer)
  }

  fileprivate func offsetToValue() -> Float {

    let progress =
      (scrollView.contentOffset.x + scrollView.contentInset.left) / contentView.bounds.size.width
    let actualProgress = Float(min(max(0, progress), 1))
    let value = ((maximumValue - minimumValue) * actualProgress) + minimumValue

    return value
  }

  fileprivate func valueToOffset(value: Float) -> CGPoint {

    let progress = (value - minimumValue) / (maximumValue - minimumValue)
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
      value = offsetToValue()
      sendActions(for: .valueChanged)
    }
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if isContinuous == false {
      value = offsetToValue()
      sendActions(for: .valueChanged)
    }
  }

  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
  {
    if decelerate == false && isContinuous == false {
      value = offsetToValue()
      sendActions(for: .valueChanged)
    }
  }
}
