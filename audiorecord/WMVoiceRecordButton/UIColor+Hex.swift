//
//  UIColor+Hex.swift
//  audiorecord
//
//  Created by apple on 2018/1/10.
//  Copyright © 2018年 wumeng. All rights reserved.
//

import Foundation

extension UIColor{
    /// 16进制转换
    ///
    /// - Parameters:
    ///   - hexValue: 传入格式：0xC6C7CA
    ///   - alpha: <#alpha description#>
    /// - Returns: <#return value description#>
    class func colorWithHex(hexValue:NSInteger,alpha:CGFloat) -> UIColor {
        return UIColor.init(red: CGFloat(Float(((hexValue & 0xFF0000) >> 16))/255.0),
                            green: CGFloat(Float(((hexValue & 0xFF00) >> 8))/255.0),
                            blue: CGFloat(Float((hexValue & 0xFF))/255.0),
                            alpha: alpha);
    }
    
    /// 16进制转换
    ///
    /// - Parameter hexValue: 传入格式：0xC6C7CA
    /// - Returns: <#return value description#>
    class func colorWithHex(hexValue:NSInteger) -> UIColor {
        return UIColor.colorWithHex(hexValue: hexValue, alpha: 1);
    }
    
    
}
