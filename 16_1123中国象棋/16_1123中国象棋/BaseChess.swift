//
//  BaseChess.swift
//  16_1123中国象棋
//
//  Created by yinxukun on 2016/11/23.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

import UIKit

enum ChessType: Int {
    case zhu = 0
    case ma = 1
    case xiang = 2
    case shi = 3
    case jiangJun = 4
    case pao = 5
    case bing = 6
}

class BaseChess: UIButton, rotateRepeat {

    var position = ChessPosition.chu

    weak var delegate: ChessesCenterProtocol?

    var isFireState = false{
        didSet{
            if isFireState {
                backgroundColor = UIColor.white
                superview?.bringSubview(toFront: self)
            }
            else{
                backgroundColor = UIColor(patternImage: UIImage(named: "棋子.jpg")!)
            }
        }
    }
    var type: ChessType = .zhu
    var name: String = ""
    var location: (Int, Int) = (0, 0)

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func config(_ type: ChessType, position: ChessPosition) {

        self.type = type
        self.position = position
        name = ["车", "马", "象", "士", "将", "炮", "兵"][type.rawValue]
        setTitle(name, for: .normal)
        backgroundColor = UIColor(patternImage: UIImage(named: "棋子.jpg")!)
        layer.cornerRadius = frame.width/2.0
        layer.masksToBounds = true
        addTarget(self, action: #selector(click), for: .touchUpInside)

        if position == .chu {
            setTitleColor(UIColor.red, for: .normal)
        }
        else{
            setTitleColor(UIColor.black, for: .normal)
        }
    }

    func click() {
        delegate?.chessClick(self)
    }

    class func initChess(_ frame: CGRect, type: ChessType, position: ChessPosition) -> BaseChess {
        var aNewChess: BaseChess? = nil
        switch type {
        case .zhu:
            aNewChess = Chesszhu(frame: frame)
        case .ma:
            aNewChess = ChessMa(frame: frame)
        case .xiang:
            aNewChess = ChessXiang(frame: frame)
        case .shi:
            aNewChess = ChessShi(frame: frame)
        case .jiangJun:
            aNewChess = ChessJiangjun(frame: frame)
        case .pao:
            aNewChess = ChessPao(frame: frame)
        case .bing:
            aNewChess = ChessBing(frame: frame)
        }
        aNewChess?.config(type, position: position)
        return aNewChess!
    }
    ///是否可移动
    func isCanMove(start: (Int, Int), end: (Int, Int), chessLayout: ChessesCenter) -> Bool {
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
///车
class Chesszhu: BaseChess {
    ///是否可移动
    override func isCanMove(start: (Int, Int), end: (Int, Int), chessLayout: ChessesCenter) -> Bool {
        var canMoveLocations: [(Int, Int)] = []   //车可以到达的位置集合
        //x--方位
        for x in (0...start.0).reversed() {
            canMoveLocations.append((x, start.1));
            let chess = delegate?.chessOnLocation((x, start.1))
            //有棋子阻断
            if chess != nil && chess != self{
                break
            }
        }
        //x++方位
        for x in start.0...8 {
            canMoveLocations.append((x, start.1));
            let chess = delegate?.chessOnLocation((x, start.1))
            //有棋子阻断
            if chess != nil && chess != self {
                break
            }
        }
        //y--方位
        for y in (0...start.1).reversed() {
            canMoveLocations.append((start.0, y));
            let chess = delegate?.chessOnLocation((start.0, y))
            //有棋子阻断
            if chess != nil && chess != self {
                break
            }
        }
        //y++方位
        for y in start.1...9 {
            canMoveLocations.append((start.0, y));
            let chess = delegate?.chessOnLocation((start.0, y))
            //有棋子阻断
            if chess != nil && chess != self {
                break
            }
        }
        print(canMoveLocations)
        if canMoveLocations.contains(where: { (x, y) -> Bool in
            if end.0 == x && end.1 == y {
                return true
            }
            return false
        }){
            return true
        }
        else{
            return false
        }
    }
}
///🐎
class ChessMa: BaseChess {
    ///是否可移动
    override func isCanMove(start: (Int, Int), end: (Int,  Int), chessLayout: ChessesCenter) -> Bool {
        if abs((start.0 - end.0)*(start.1 - end.1)) == 2 {
            var errorLocation = (0, 0)
            //x轴向跳两格子
            if abs(start.0 - end.0) == 2 {
                errorLocation = ((start.0 + end.0)/2, start.1)
            }
            //y轴向跳两格子
            else{
                errorLocation = (start.0 ,(start.1 + end.1)/2)
            }
            if delegate?.chessOnLocation(errorLocation) != nil {
                return false
            }
            else{
                return true
            }
        }
        return false
    }
}
///象
class ChessXiang: BaseChess {
    ///是否可移动
    override func isCanMove(start: (Int, Int), end: (Int,  Int), chessLayout: ChessesCenter) -> Bool {
        if position == .chu && end.1 > 4 {
            return false
        }
        if position == .han && end.1 <= 4 {
            return false
        }
        if abs((start.0 - end.0)*(start.1 - end.1)) == 4 {
            let errorLocation = ((start.0 + end.0)/2, (start.1 + end.1)/2)
            if delegate?.chessOnLocation(errorLocation) != nil {
                return false
            }
            else{
                return true
            }
        }
        return false
    }
}
///士
class ChessShi: BaseChess {
    ///是否可移动
    override func isCanMove(start: (Int, Int), end: (Int,  Int), chessLayout: ChessesCenter) -> Bool {
        if abs((start.0 - end.0) * (start.1 - end.1)) == 1 {
            if (end.0 >= 3 && end.0 <= 5 ) && (end.1 <= 2 || end.1 >= 7) {
                return true
            }
        }
        return false
    }
}
///将军
class ChessJiangjun: BaseChess {
    ///是否可移动
    override func isCanMove(start: (Int, Int), end: (Int,  Int), chessLayout: ChessesCenter) -> Bool {
        if abs((start.0 - end.0) + (start.1 - end.1)) == 1 {
            if (end.0 >= 3 && end.0 <= 5 ) && (end.1 <= 2 || end.1 >= 7) {
                return true
            }
        }
        return false
    }
}
///炮
class ChessPao: BaseChess {
    ///是否可移动
    override func isCanMove(start: (Int, Int), end: (Int, Int), chessLayout: ChessesCenter) -> Bool {
        var canMoveLocations: [(Int, Int)] = []   //车可以到达的位置集合
        //x--方位
        for x in (0...start.0).reversed() {
            let chess = delegate?.chessOnLocation((x, start.1))
            //有棋子阻断
            if chess != nil && chess != self{
                break
            }
            canMoveLocations.append((x, start.1));
        }
        //x++方位
        for x in start.0...8 {
            let chess = delegate?.chessOnLocation((x, start.1))
            //有棋子阻断
            if chess != nil && chess != self {
                break
            }
            canMoveLocations.append((x, start.1));
        }
        //y--方位
        for y in (0...start.1).reversed() {
            let chess = delegate?.chessOnLocation((start.0, y))
            //有棋子阻断
            if chess != nil && chess != self {
                break
            }
            canMoveLocations.append((start.0, y));
        }
        //y++方位
        for y in start.1...9 {
            let chess = delegate?.chessOnLocation((start.0, y))
            //有棋子阻断
            if chess != nil && chess != self {
                break
            }
            canMoveLocations.append((start.0, y));
        }
        ///炮比猪少一个吃子位置，多一个隔位打
        //x--方位
        var xReverseCount: Int = 0
        for x in (0...start.0).reversed() {
            let chess = delegate?.chessOnLocation((x, start.1))
            //有棋子阻断
            if chess != nil && chess != self{
                xReverseCount += 1
                if xReverseCount == 2 {
                    canMoveLocations.append((x, start.1));
                }
            }
        }
        //x++方位
        var xAddCount: Int = 0
        for x in start.0...8 {
            let chess = delegate?.chessOnLocation((x, start.1))
            //有棋子阻断
            if chess != nil && chess != self{
                xAddCount += 1
                if xAddCount == 2 {
                    canMoveLocations.append((x, start.1));
                }
            }
        }
        //y--方位
        var yReverseCount = 0
        for y in (0...start.1).reversed() {
            let chess = delegate?.chessOnLocation((start.0, y))
            //有棋子阻断
            if chess != nil && chess != self{
                yReverseCount += 1
                if yReverseCount == 2 {
                    canMoveLocations.append((start.0, y));
                }
            }
        }
        //y++方位
        var yAddCount = 0
        for y in start.1...9 {
            let chess = delegate?.chessOnLocation((start.0, y))
            //有棋子阻断
            if chess != nil && chess != self{
                yAddCount += 1
                if yAddCount == 2 {
                    canMoveLocations.append((start.0, y));
                }
            }
        }

        print(canMoveLocations)
        if canMoveLocations.contains(where: { (x, y) -> Bool in
            if end.0 == x && end.1 == y {
                return true
            }
            return false
        }){
            return true
        }
        else{
            return false
        }
    }
}
///兵
class ChessBing: BaseChess {

    override func isCanMove(start: (Int, Int), end: (Int, Int), chessLayout: ChessesCenter) -> Bool {
        if position == .chu {
            if end.1 < start.1 {
                return false
            }
            //过河前
            if(start.1 <= 4){
                if (end.1 - start.1 == 1) && start.0 == end.0 {
                    return true
                }
                else{
                    return false
                }
            }
            //过河后
            else{
                if(abs((start.0 - end.0) + (start.1 - end.1)) == 1){
                    return true
                }
                else{
                    return false
                }
            }
        }
        //B方
        else{
            if end.1 > start.1 {
                return false
            }
            //过河前
            if(start.1 > 4){
                if (end.1 - start.1 == -1) && start.0 == end.0 {
                    return true
                }
                else{
                    return false
                }
            }
            //过河后
            else{
                if(abs((start.0 - end.0) + (start.1 - end.1)) == 1){
                    return true
                }
                else{
                    return false
                }
            }
        }
    }
}




