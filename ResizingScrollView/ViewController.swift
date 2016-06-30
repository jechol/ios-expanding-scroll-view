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