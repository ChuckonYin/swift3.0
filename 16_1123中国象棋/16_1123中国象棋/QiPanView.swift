//
//  QiPanView.swift
//  16_1123中国象棋
//
//  Created by yinxukun on 2016/11/23.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

import UIKit

//9*10点 8*9格子
class QiPanView: UIView{

    let lineWidth: CGFloat = 2.0

    var rotarion: CGFloat = 0.0

    var chessesCenter: ChessesCenter?

    var width: CGFloat = 0.0

    var height: CGFloat = 0.0

    lazy var firePositionBtn: BaseChess = {
        let firePositionBtn = BaseChess.initChess(CGRect(x: 20, y:  420, width: 45, height:45), type: .jiangJun, position: .han)
        firePositionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 35)
        return firePositionBtn
    }()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.width*1.3))
        backgroundColor = UIColor(patternImage: UIImage(named: "棋盘.jpg")!)
        width = frame.width/10.0
        height = width
        firePositionBtn.center = CGPoint(x: self.frame.width/2.0, y: self.frame.height - 50)
        addSubview(firePositionBtn)
        chessesCenterHiddenBtns()
        firePositionBtn.startRotate()
    }

    func chessesCenterHiddenBtns(){
        //暗桩布局
        chessesCenter = ChessesCenter.init(delegate: self, chessSize: (width, height))
        for btn in (chessesCenter?.hiddenBtns)! {
            btn.frame = CGRect(x: 0, y: 0, width: width, height: height)
            let x = width*CGFloat(btn.location.0 + 1)
            let y = height*CGFloat(btn.location.1 + 1)
//            btn.setTitle(String("\(btn.location.0)\(btn.location.1)"), for: UIControlState.normal)
            btn.center = CGPoint(x: x, y: y)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            addSubview(btn)
        }
        //棋子布局
        for chess: BaseChess in (chessesCenter?.chu_chesses)! {
            addSubview(chess)
            chessesCenter?.chessMoveTo(chess: chess, location: chess.location)
        }
        for chess: BaseChess in (chessesCenter?.han_chesses)! {
            addSubview(chess)
            chessesCenter?.chessMoveTo(chess: chess, location: chess.location)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        ///绘制网格
        let path = UIBezierPath()
        for x in 1...9 {
            path.move(to: CGPoint(x:width*CGFloat(x), y:height))
            if (x != 1 && x != 9) {
                //楚河汉界
                path.addLine(to: CGPoint(x:width*CGFloat(x), y:height*5.0))
                path.move(to: CGPoint(x:width*CGFloat(x), y:height*6.0))
            }
            path.addLine(to: CGPoint(x:width*CGFloat(x), y:height*10.0))
        }
        for y in 1...10 {
            path.move(to: CGPoint(x:width, y:height*CGFloat(y)))
            path.addLine(to: CGPoint(x:width*9.0, y:height*CGFloat(y)))
        }
        ///绘制斜线
        let xiexianPoints = [((4.0, 1.0), (6.0, 3.0)),
                             ((6.0, 1.0), (4.0, 3.0)),
                             ((4.0, 8.0), (6.0, 10.0)),
                             ((6.0, 8.0), (4.0, 10.0))]
        for p in xiexianPoints {
            let p1 = CGPoint(x: width * CGFloat(p.0.0), y: height * CGFloat(p.0.1))
            let p2 = CGPoint(x: width * CGFloat(p.1.0), y: height * CGFloat(p.1.1))
            path.move(to: p1)
            path.addLine(to: p2)
        }
        path.lineWidth = lineWidth
        path.stroke()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QiPanView: QipanProtocol{
    ///fire方切换
    func chessesCenterFirePositionChanged(_ position: ChessPosition) {
        if position == .chu {
            firePositionBtn.setTitle("楚", for: .normal)
            firePositionBtn.setTitleColor(UIColor.red, for: .normal)
            chessesCenter?.chessFindJinagJun(.chu)?.startRotate() //找到红字将军并旋转
            chessesCenter?.chessFindJinagJun(.han)?.stopRotate() //找到黑字将军并停止旋转
        }
        else{
            firePositionBtn.setTitle("汉", for: .normal)
            firePositionBtn.setTitleColor(UIColor.black, for: .normal)
            chessesCenter?.chessFindJinagJun(.han)?.startRotate()
            chessesCenter?.chessFindJinagJun(.chu)?.stopRotate()
        }
    }

    func chessesCenterGameOver() {
        firePositionBtn.setTitle("😊", for: .normal)
        print("老头死了，game over")
    }
}

