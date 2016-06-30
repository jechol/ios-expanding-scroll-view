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

class ExpandTopScrollView: UIScrollView {

  var rows = [UIView]() { didSet { configure() } }
  @IBInspectable var minHeightOverWidth: CGFloat = 0.4 { didSet { configure() } }
  @IBInspectable var maxHeightOverWidth: CGFloat = 0.8 { didSet { configure() } }
  @IBInspectable var enableBottomInset: Bool = false

  var minHeight: CGFloat {
    return width * minHeightOverWidth
  }
  var maxHeight: CGFloat {
    return width * maxHeightOverWidth
  }

  private func configure() {
    delegate = self
    subviews.forEach { $0.removeFromSuperview() }

//    var y = 0 as CGFloat

    rows.enumerate().forEach { (index, view) in
//      let rowHeight = index == 0 ? self.maxHeight : self.minHeight
//      view.frame = CGRectMake(0, y, self.frame.width, rowHeight)

      let tapGr = UITapGestureRecognizer(target: self, action: #selector(ExpandTopScrollView.didSelect))
      view.addGestureRecognizer(tapGr)

//      y += rowHeight
      self.addSubview(view)
    }

//    let bottomInset = frame.height - maxHeight
//    contentSize.width = frame.width
//    contentSize.height = enableBottomInset ? (y + bottomInset) : y
  }

  func didSelect() {
    NSLog("clicked")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    NSLog("layoutSubview()")
    let invisibleHeight = offset - CGFloat(curIndex) * minHeight
    let visibleHeight = (maxHeight - invisibleHeight)
    let visibleRatio = visibleHeight / maxHeight
    let curHeight = visibleRatio * maxHeight
    let nextHeight = (minHeight + maxHeight) - curHeight

    var y: CGFloat = 0
    for i in 0..<rows.count {
      var height: CGFloat!
      switch i {
      case curIndex:
        height = curHeight
      case curIndex + 1:
        height = nextHeight
      default:
        height = minHeight
      }

      if i == curIndex {
        height = curHeight
      } else if i == curIndex + 1 {
        height = nextHeight
      } else {
        height = minHeight
      }

      rows[i].frame = CGRectMake(0, y, width, height)
      y += height
    }


    let bottomInset = frame.height - maxHeight
    contentSize.width = width
    contentSize.height = enableBottomInset ? (y + bottomInset) : y
  }

  var curIndex: Int {
    return Int(offset / minHeight)
  }

  var offset: CGFloat {
    return contentOffset.y < 0 ? 0 : contentOffset.y
  }

}

extension ExpandTopScrollView: UIScrollViewDelegate {

  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard !decelerate else { return }

    NSLog("didEndDraggin")
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    NSLog("didEndDecelerating")
  }
  
}


class DemoRow: UIView {

  lazy var label: UILabel = { [unowned self] in
    let v = UILabel()
    v.textColor = UIColor.magentaColor()
    self.addSubview(v)
    return v
  }()

  override func layoutSubviews() {
    super.layoutSubviews()

    label.center = self.bounds.center
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