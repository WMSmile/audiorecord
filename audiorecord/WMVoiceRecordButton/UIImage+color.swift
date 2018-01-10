//
//  UIImage+color.swift
//  audiorecord
//
//  Created by apple on 2018/1/10.
//  Copyright © 2018年 wumeng. All rights reserved.
//

import Foundation

extension UIImage {
    /// UIColor to UIimage
    ///
    /// - Parameters:
    ///   - color: <#color description#>
    ///   - size: <#size description#>
    /// - Returns: <#return value description#>
    class func imageWithColor(color:UIColor,size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        color.set();
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height));
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return image;
    }
    
}
