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

class DemoRow: UIView, ExpandableView {

  var index: Int! { didSet { configure() } }
  var expandedRatio: CGFloat = 1.0 { didSet { configure() } }

  override init(frame: CGRect) {
    super.init(frame: frame)

    initSetup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  let label = UILabel()

  private func initSetup() {
    label.textColor = UIColor.magentaColor()
    self.addSubview(label)
  }

  private func configure() {
    label.text = "\(index): \(NSString(format:"%.3f", expandedRatio))"
    label.sizeToFit()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    label.center = CGPointMake(bounds.midX, bounds.midY + height * (1.0 - expandedRatio))
  }

}
