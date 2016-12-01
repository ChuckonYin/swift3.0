//
//  chessesCenter.swift
//  16_1123中国象棋
//
//  Created by yinxukun on 2016/11/23.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

import UIKit

enum ChessPosition: Int{
    case chu = 0  ///楚
    case han = 1  ///汉
}

///棋子管理中心
class ChessesCenter: NSObject {

    var firePosition = ChessPosition.chu //先手方
    var hiddenBtns: [HiddenLocationBtn] = []
    var chu_chesses: [BaseChess] = []
    var han_chesses: [BaseChess] = []
    var all_chesses: [BaseChess] {
        return chu_chesses + han_chesses
    }
    weak var delegate: QipanProtocol?

    convenience init(delegate: QipanProtocol, chessSize:(CGFloat, CGFloat)) {
        self.init()
        self.delegate = delegate
        layoutAllChess(chessSize)
    }
    ///布局所有明、暗棋子
    func layoutAllChess(_ chessSize: (CGFloat, CGFloat)) {
        //布局暗桩
        for x in 0...8{
            for y in 0...9 {
                let hiddenBtn: HiddenLocationBtn = HiddenLocationBtn()
                hiddenBtn.isHighlighted = true
                hiddenBtns.append(hiddenBtn)
                hiddenBtn.location = (x, y)
                hiddenBtn.delegate = self
            }
        }
        ///布局A方棋子
        //棋子类型
        let types: [ChessType] = [.zhu, .zhu,
                                  .ma, .ma,
                                  .xiang, .xiang,
                                  .shi, .shi,
                                  .jiangJun,
                                  .pao, .pao,
                                  .bing, .bing, .bing, .bing, .bing]
        //A方位置
        let chu_locations = [(0, 0), (8, 0), //zhu
                          (1, 0), (7, 0), //ma
                          (2, 0), (6, 0), //xiang
                          (3, 0), (5, 0), //shi
                          (4, 0),         //jiangJun
                          (1, 2), (7, 2),  // pao
                          (0, 3), (2, 3), (4, 3), (6, 3), (8, 3)] //bing
        //B方位置
        let han_locations = [(0, 9), (8, 9),
                          (1, 9), (7, 9),
                          (2, 9), (6, 9),
                          (3, 9), (5, 9),
                          (4, 9),
                          (1, 7), (7, 7),
                          (0, 6), (2, 6), (4, 6), (6, 6), (8, 6)]

        for i in 0...15 {
            ///布局A方棋子
            let chu_chess = BaseChess.initChess(CGRect(x: 0, y: 0, width: chessSize.0, height: chessSize.1), type: types[i], position: .chu)
            chu_chess.delegate = self
            chu_chess.location = chu_locations[i]
            chu_chesses.append(chu_chess)
            ///布局B方棋子
            let han_chess = BaseChess.initChess(CGRect(x: 0, y: 0, width: chessSize.0, height: chessSize.1), type: types[i], position: .han)
            han_chess.delegate = self
            han_chess.location = han_locations[i]
            han_chesses.append(han_chess)
        }
    }
}

extension ChessesCenter: HiddenLocationBtnDelegate{
    func hiddenBtnEmptyLocationClick(_ location: (Int, Int)) {
        print("点击空白区域")
        //取消所有按钮高亮
        let startChess = chessFindFiringChess()
        guard startChess != nil else {
            return //无高亮棋子
        }
        guard startChess?.position == firePosition else {
            return //非主攻方
        }
        let isCanMove = startChess?.isCanMove(start: (startChess?.location)!, end: location, chessLayout: self)
        if isCanMove == true  {
            self.chessMoveTo(chess: startChess!, location: location)
        }
    }
}

extension ChessesCenter: ChessesCenterProtocol{
    func firePositionExchange() {
        switch firePosition {
        case .chu:
            firePosition = .han
        case .han:
            firePosition = .chu
        }
        delegate?.chessesCenterFirePositionChanged(firePosition)
    }

    func chessClick(_ chess: BaseChess) {
        let fireChess = chessFindFiringChess()
        //没有高亮棋子
        guard fireChess != nil else {
            _ = chessBecomeFiring(chess.location)
            return
        }
        //已经有一颗高亮棋子，不是fire方
        guard fireChess?.position == firePosition else {
            _ = chessBecomeFiring(chess.location)
            return
        }
        //两颗棋子来自同一方
        guard fireChess?.position != chess.position else {
            _ = chessBecomeFiring(chess.location)
            return
        }
        //吃子
        let isCanEat = fireChess?.isCanMove(start: (fireChess?.location)!, end: chess.location, chessLayout: self);
        if isCanEat == true {
            _ = eatChess(fireChess!, dieChess: chess)
        }
    }

    ///仅仅移动棋子
    func chessMoveTo(chess: BaseChess, location: (Int, Int)) {
        var toLocationBtn: HiddenLocationBtn?
        for btn:HiddenLocationBtn in hiddenBtns {
            if btn.location == location {
                toLocationBtn = btn
            }
        }
        guard toLocationBtn != nil else {
            return
        }
        let duration = CGFloat(abs(chess.location.0 - location.0) + abs(chess.location.1 - location.1))*0.1
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: .curveEaseInOut, animations: {
            chess.center = (toLocationBtn?.center)!
            chess.location = location
        }, completion: { (complete) in
        })
        firePositionExchange()
    }
    ///查找当前高亮棋子
    func chessFindFiringChess() -> BaseChess? {
        for chess in all_chesses {
            if chess.isFireState {
                return chess
            }
        }
        return nil
    }
    ///location -> 棋子
    func chessOnLocation(_ location: (Int, Int)) -> BaseChess? {
        for chess in all_chesses {
            if chess.location == location {
                return chess
            }
        }
        return nil
    }
    //切换高亮棋子
    func chessBecomeFiring(_ location: (Int, Int)) -> Bool{
        let chess = chessOnLocation(location)
        if chess != nil {
            //高亮调整
            for chess in all_chesses {
                chess.isFireState = false
            }
            chess?.isFireState = true
        }
        return false
    }
    //吃子
    func eatChess(_ fireChess: BaseChess, dieChess: BaseChess) -> Bool {
        //同方不可吃
        guard fireChess.position != dieChess.position else {
            return false
        }

        chessMoveTo(chess: fireChess, location: dieChess.location)

        if dieChess.type == .jiangJun {
            delegate?.chessesCenterGameOver()
        }

        dieChess.removeFromSuperview()

        let dieChessIndex1 = chu_chesses.index(of: dieChess)
        if dieChessIndex1 != nil {
            chu_chesses.remove(at: dieChessIndex1!)
        }
        let dieChessIndex2 = han_chesses.index(of: dieChess)
        if dieChessIndex2 != nil {
            han_chesses.remove(at: dieChessIndex2!)
        }
        return true
    }
    
    func chessFindJinagJun(_ position: ChessPosition) -> BaseChess? {
        for chess in all_chesses {
            if chess.position == position && chess.type == .jiangJun {
                return chess
            }
        }
        return nil
    }
}

