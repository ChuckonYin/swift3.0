//
//  ChessPrototcol.swift
//  16_1123中国象棋
//
//  Created by yinxukun on 2016/11/27.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

import UIKit

///棋子旋转协议
protocol rotateRepeat {
    func startRotate()
    func stopRotate()
}
extension rotateRepeat where Self: UIView{
    func startRotate() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = M_PI * 2.0;
        rotationAnimation.duration = 3;
        rotationAnimation.isCumulative = true;
        rotationAnimation.repeatCount = Float(Int.max);
        layer.add(rotationAnimation, forKey: "rotation")
    }
    func stopRotate() {
        layer.removeAllAnimations()
    }
}
///棋盘视图需要遵守的协议
protocol QipanProtocol: NSObjectProtocol{
    ///老头子被吃了
    func chessesCenterFirePositionChanged(_ position: ChessPosition)
    func chessesCenterGameOver()
}
///棋盘管理中心必须提供的接口
protocol ChessesCenterProtocol: NSObjectProtocol {
    func chessClick(_ chess: BaseChess)
    ///仅仅移动棋子
    func chessMoveTo(chess: BaseChess, location: (Int, Int))
    ///查找当前高亮棋子
    func chessFindFiringChess() -> BaseChess?
    ///location -> 棋子
    func chessOnLocation(_ location: (Int, Int)) -> BaseChess?
    //切换高亮棋子
    func chessBecomeFiring(_ location: (Int, Int)) -> Bool
    //找将军
    func chessFindJinagJun(_ position: ChessPosition) -> BaseChess?
    //切换进攻方
    func firePositionExchange()
}


