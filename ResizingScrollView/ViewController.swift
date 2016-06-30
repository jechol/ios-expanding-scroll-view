//
//  ViewController.swift
//  ResizingScrollView
//
//  Created by Jechol Lee on 6/29/16.
//  Copyright © 2016 Org. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let count = 20
    let sv = view as! ExpandingScrollView
    sv.rows = (0..<count).map { i in
      let v = DemoRow()
      v.index = i
      v.backgroundColor = UIColor.init(white: CGFloat(i) / CGFloat(count), alpha: 1.0)
      return v
    }

    sv.showsVerticalScrollIndicator = false
  }
}

class ExpandableView: UIView {
  var expandedRatio: CGFloat = 1.0 { didSet { setNeedsLayout() } }
}

class ExpandingScrollView: UIScrollView {

  var rows = [ExpandableView]() { didSet { configure() } }
  @IBInspectable var minHeightOverWidth: CGFloat = 0.2 { didSet { configure() } }
  @IBInspectable var maxHeightOverWidth: CGFloat = 0.8 { didSet { configure() } }
  @IBInspectable var expandAboveRows: Bool = true
  @IBInspectable var enableBottomInset: Bool = true

  var minHeight: CGFloat {
    return width * minHeightOverWidth
  }
  var maxHeight: CGFloat {
    return width * maxHeightOverWidth
  }

  var aboveHeight: CGFloat {
    return expandAboveRows ? maxHeight : minHeight
  }

  var offset: CGFloat {
    return contentOffset.y < 0 ? 0 : contentOffset.y
  }

  var curIndex: Int {
    return Int(offset / aboveHeight)
  }

  var rowOffset: CGFloat {
    return offset - CGFloat(curIndex) * aboveHeight
  }

  private func configure() {
    delegate = self
    decelerationRate = UIScrollViewDecelerationRateFast
    subviews.forEach { $0.removeFromSuperview() }

    rows.enumerate().forEach { (index, view) in
      let tapGr = UITapGestureRecognizer(target: self, action: #selector(ExpandingScrollView.didSelect))
      view.addGestureRecognizer(tapGr)
      view.clipsToBounds = true
      self.addSubview(view)
    }
  }

  func didSelect() {
    NSLog("clicked")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let invisibleRatio = rowOffset / aboveHeight
    let curHeight = aboveHeight + (1 - invisibleRatio) * (maxHeight - aboveHeight)
    let nextHeight = minHeight + invisibleRatio * (maxHeight - minHeight)

    setFrames(aboveHeight: aboveHeight, curHeight: curHeight, nextHeight: nextHeight)
  }

  private func setFrames(aboveHeight aboveHeight: CGFloat, curHeight: CGFloat, nextHeight: CGFloat) {
    var y: CGFloat = 0

    for i in 0..<rows.count {
      var height: CGFloat!

      switch i {
      case 0..<curIndex:
        height = aboveHeight
      case curIndex:
        height = curHeight
      case curIndex + 1:
        height = nextHeight
      default:
        height = minHeight
      }

      let row = rows[i]
      row.frame = CGRectMake(0, y, width, height)
      row.expandedRatio = height / maxHeight

      y += height
    }

    let bottomInset = enableBottomInset ? (height - maxHeight) : 0
    contentSize.width = width
    contentSize.height = CGFloat(rows.count) * aboveHeight + bottomInset
  }
}

extension ExpandingScrollView: UIScrollViewDelegate {
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard let sv = scrollView as? ExpandingScrollView else { return }

    var y = targetContentOffset.memory.y

    switch velocity.y {
    case let v where v < -0.1:
      y = floor(y / sv.aboveHeight) * sv.aboveHeight
    case let v where v > 0.1:
      y = ceil(y / sv.aboveHeight) * sv.aboveHeight
    default:
      y = round(y / sv.aboveHeight) * sv.aboveHeight
    }

    targetContentOffset.memory.y = y
  }
}


class DemoRow: ExpandableView {

  var index: Int!

  lazy var label: UILabel = { [unowned self] in
    let v = UILabel()
    v.textColor = UIColor.magentaColor()
    self.addSubview(v)
    return v
  }()

  override func layoutSubviews() {
    super.layoutSubviews()

    label.text = "\(index): \(NSString(format:"%.3f", expandedRatio))"
    label.sizeToFit()

    label.center = CGPointMake(bounds.midX, bounds.midY + height * (1.0 - expandedRatio))
  }
}

extension CGRect {
  var center: CGPoint {
    return CGPointMake(midX, midY)
  }
}

extension UIView {
  var width: CGFloat {
    return frame.size.width
  }
  var height: CGFloat {
    return frame.size.height
  }
}
