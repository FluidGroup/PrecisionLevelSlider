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

  /// default 0.0. this value will be pinned to min/max
  open dynamic var value: Float = 0 {
    didSet {

      guard !scrollView.isDecelerating && !scrollView.isDragging else {
        return
      }

      let offset = valueToOffset(value: value)

      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {

        self.scrollView.setContentOffset(offset, animated: false)

      }) { (finish) in
      }
    }
  }

  /// default 0.0. the current value may change if outside new min value
  open dynamic var minimumValue: Float = 0 {
    didSet {
      let offset = valueToOffset(value: value)

      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {

        self.scrollView.setContentOffset(offset, animated: false)

      }) { (finish) in
      }
    }
  }

  /// default 1.0. the current value may change if outside new max value
  open dynamic var maximumValue: Float = 1 {
    didSet {
      let offset = valueToOffset(value: value)

      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {

        self.scrollView.setContentOffset(offset, animated: false)

      }) { (finish) in
      }
    }
  }

  open var isContinuous: Bool = true

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

    let inset = bounds.width / 2

    scrollView.contentInset = UIEdgeInsetsMake(0, inset, 0, inset)
    let offset = valueToOffset(value: value)
    scrollView.setContentOffset(offset, animated: true)

    gradientLayer.frame = bounds
  }

  func setup() {

    layer.mask = gradientLayer

    backgroundColor = UIColor.clear

    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self

    addSubview(scrollView)
    scrollView <- [
      Edges()
    ]

    let views: [UIView] = (0...30).map { i -> UIView in
      if i % 5 == 0 {

        let tick = UIView()
        tick <- [
          Width(1)
        ]
        tick.backgroundColor = UIColor.white
        return tick
      } else {

        let containerView = UIView()

        let tick = UIView()
        containerView.addSubview(tick)

        tick <- [
          Top(4),
          Bottom(4),
          Right(),
          Left(),
          Width(1)
        ]

        tick.backgroundColor = UIColor(white: 1, alpha: 0.8)
        return containerView
      }
    }

    let measureStackView = UIStackView(arrangedSubviews: views)
    measureStackView.axis = .horizontal
    measureStackView.distribution = .equalSpacing

    scrollView.addSubview(measureStackView)

    let measureContainerView = UIView()
    measureContainerView.addSubview(measureStackView)

    measureStackView <- [
      CenterY(),
      Height(16),
      Right(),
      Left(),
    ]

    scrollView.addSubview(measureContainerView)

    measureContainerView <- [
      Top(),
      Right(),
      Bottom(),
      Left(),
      Height().like(scrollView),
      Width().like(scrollView),
    ]

    let centerTickView = UIView()
    centerTickView.isUserInteractionEnabled = false
    centerTickView.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
    addSubview(centerTickView)

    centerTickView <- [
      CenterX(),
      Top(),
      Bottom(),
      Width(1),
    ]
  }

  private let scrollView = UIScrollView()
  private let gradientLayer: CAGradientLayer = {

    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
    gradientLayer.locations = [0, 0.4, 0.6, 1]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0)

    return gradientLayer
  }()

  fileprivate func offsetToValue() -> Float {

    let progress = 1 + ((scrollView.contentOffset.x - (scrollView.bounds.width / 2)) / scrollView.bounds.width)
    let actualProgress = Float(min(max(0, progress), 1))

    let value = ((maximumValue - minimumValue) * actualProgress) + minimumValue

    return value
  }

  fileprivate func valueToOffset(value: Float) -> CGPoint {

    let progress = (value - minimumValue) / (maximumValue - minimumValue)
    let x = (scrollView.bounds.width * CGFloat(progress)) - (scrollView.bounds.width / 2)
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

    value = offsetToValue()

    if isContinuous {
      sendActions(for: .valueChanged)
    }
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    sendActions(for: .valueChanged)
  }
}
