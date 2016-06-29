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
  @IBInspectable var minHeight: CGFloat = 100.0 { didSet { configure() } }
  @IBInspectable var maxHeight: CGFloat = 200.0 { didSet { configure() } }
  @IBInspectable var enableBottomInset: Bool = false

  private func configure() {
    self.subviews.forEach { $0.removeFromSuperview() }

    var y = 0 as CGFloat

    rows.enumerate().forEach { (index, view) in
      let rowHeight = index == 0 ? self.maxHeight : self.minHeight
      view.frame = CGRectMake(0, y, self.frame.width, rowHeight)

      let tapGr = UITapGestureRecognizer(target: self, action: #selector(ExpandTopScrollView.didSelect))
      view.addGestureRecognizer(tapGr)

      y += rowHeight
      self.addSubview(view)
    }

    let bottomInset = frame.height - maxHeight
    contentSize.width = frame.width
    contentSize.height = enableBottomInset ? (y + bottomInset) : y
  }

  func didSelect() {

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
    print(label.frame)
  }
}

extension CGRect {
  var center: CGPoint {
    return CGPointMake(midX, midY)
  }
}