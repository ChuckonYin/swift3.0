//
//  HiddenLocationBtn.swift
//  16_1123中国象棋
//
//  Created by yinxukun on 2016/11/24.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

import UIKit

protocol HiddenLocationBtnDelegate: NSObjectProtocol{
    func hiddenBtnEmptyLocationClick(_ location: (Int, Int))
}

class HiddenLocationBtn: UIButton {

    var isEmpty: Bool = true
    var location: (Int, Int) = (0, 0)
    weak var delegate: HiddenLocationBtnDelegate?

    override init(frame: CGRect){
        super.init(frame: frame)
        addTarget(self, action: #selector(click), for: .touchUpInside)
    }

    func click() {
        delegate?.hiddenBtnEmptyLocationClick(location)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

