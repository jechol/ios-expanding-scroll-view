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
    // Do any additional setup after loading the view, typically from a nib.

    let sv = view as! ExpandTopScrollView
    sv.rows = (0..<12).map { i in
      let v = DemoRow()
      let gray = CGFloat(i) / 12.0
      v.backgroundColor = UIColor.init(white: gray, alpha: 1.0)
      v.label.text = "Row \(i)"
      v.label.sizeToFit()
      return v
    }

    sv.showsVerticalScrollIndicator = false
  }
}

class ExpandableView: UIView {
  var expandedRatio: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
}

class ExpandTopScrollView: UIScrollView {

  var rows = [ExpandableView]() { didSet { configure() } }
  @IBInspectable var minHeightOverWidth: CGFloat = 0.2 { didSet { configure() } }
  @IBInspectable var maxHeightOverWidth: CGFloat = 0.8 { didSet { configure() } }
  @IBInspectable var expandAboveRows: Bool = false
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

  private func configure() {
    delegate = self
    subviews.forEach { $0.removeFromSuperview() }

    rows.enumerate().forEach { (index, view) in
      let tapGr = UITapGestureRecognizer(target: self, action: #selector(ExpandTopScrollView.didSelect))
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


//    NSLog("layoutSubview()")
    expandAboveRows ? expandAllAboveCurrent() : expandCurrentOnly()
  }

  private func expandCurrentOnly() {
    let curIndex = Int(offset / aboveHeight)

    let invisibleHeight = offset - CGFloat(curIndex) * aboveHeight
    let invisibleRatio = invisibleHeight / aboveHeight
    let curHeight = aboveHeight + (1 - invisibleRatio) * (maxHeight - aboveHeight)
    let nextHeight = minHeight + invisibleRatio * (maxHeight - minHeight)

    setFrames(curIndex: curIndex, aboveHeight: aboveHeight, curHeight: curHeight, nextHeight: nextHeight)
  }

  private func expandAllAboveCurrent() {
    let curIndex = Int(offset / aboveHeight)

    let invisibleHeight = offset - CGFloat(curIndex) * aboveHeight
    let invisibleRatio = invisibleHeight / maxHeight
    let curHeight = maxHeight
    let nextHeight = minHeight + invisibleRatio * (maxHeight - minHeight)

    setFrames(curIndex: curIndex, aboveHeight: aboveHeight, curHeight: curHeight, nextHeight: nextHeight)
  }

  private func setFrames(curIndex curIndex: Int, aboveHeight: CGFloat, curHeight: CGFloat, nextHeight: CGFloat) {
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
    contentSize.height = y + bottomInset
  }

  var offset: CGFloat {
    return contentOffset.y < 0 ? 0 : contentOffset.y
  }
}

extension UIScrollView {
}

extension ExpandTopScrollView: UIScrollViewDelegate {

  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard !decelerate else { return }
    guard let scrollView = scrollView as? ExpandTopScrollView else { return }

//    let rowY = scrollView.cur

  }

  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    NSLog("willEndDragging")
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    NSLog("didEndDecelerating")
  }
  
}


class DemoRow: ExpandableView {

  lazy var label: UILabel = { [unowned self] in
    let v = UILabel()
    v.textColor = UIColor.magentaColor()
    self.addSubview(v)
    return v
  }()

  override func layoutSubviews() {
    super.layoutSubviews()

    label.center = CGPointMake(bounds.midX, bounds.midY + height * (1.0 - expandedRatio))
    label.text = "\(expandedRatio)"
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