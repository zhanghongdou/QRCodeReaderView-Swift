//
//  Category.swift

//
//  Created by haohao on 16/7/22.
//  Copyright © 2016年 haohao. All rights reserved.
//
//这个创建的swift  file专门用来写扩展的
import Foundation
import UIKit

//MARK: ------扩展button
extension UIButton {
 
    enum HHButtonEdgeInsetsStyle: Int {
        case Top = 1 //image在上，lebel在下
        case Left    //image在左，lebel在右
        case Bottom  //image在下，lebel在上
        case Right   //image在右，lebel在左
    }
    
    func layoutButtonWithEdgesInsetsStyleWithSpace(style : HHButtonEdgeInsetsStyle, space : CGFloat) {
        //首先得到imageView和titleLabel的宽高
        let imageWith = self.imageView?.frame.size.width
        let imageHeight = self.imageView?.frame.size.height
        var labelWith : CGFloat = 0
        var labelHeight : CGFloat = 0
        if kIOS8 == 1 {
       //由于ios8中titleLabel的size是0，用下面的这种设置
            labelWith = (self.titleLabel?.intrinsicContentSize().width)!
            labelHeight = (self.titleLabel?.intrinsicContentSize().height)!
        }else{
            labelWith = (self.titleLabel?.frame.size.width)!
            labelHeight = (self.titleLabel?.frame.size.height)!
        }
        var imageEdgeInsets = UIEdgeInsetsZero
        var labelEdgeInsets = UIEdgeInsetsZero
        //根据style和space得到imageEdgeInsets和labelEdgeInsets的值
        switch style {
        case .Top:
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight - space / 2, 0, 0, -labelWith)
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith!, -imageHeight! - space / 2, 0)
        case .Left:
            imageEdgeInsets = UIEdgeInsetsMake(0, -space / 2, 0, space / 2)
            labelEdgeInsets = UIEdgeInsetsMake(0, space / 2, 0, -space / 2)
        case .Bottom:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight - space / 2, -labelWith)
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight! - space / 2, -imageWith!, 0, 0)
        default:
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWith + space / 2, 0, -labelWith - space / 2)
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith! - space / 2, 0, imageWith! + space / 2)
        }
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
}

































