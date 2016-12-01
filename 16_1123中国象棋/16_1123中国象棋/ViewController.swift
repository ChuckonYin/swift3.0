//
//  ViewController.swift
//  16_1123中国象棋
//
//  Created by yinxukun on 2016/11/23.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let qiPan = QiPanView.init(frame: CGRect.init(x: 0, y: 100, width: 37*10.0, height: 37*18.0))
        view.addSubview(qiPan)

    }
}

