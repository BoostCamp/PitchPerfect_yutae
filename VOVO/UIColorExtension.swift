//
//  UIColorExtension.swift
//  PitchPerfect
//
//  Created by 최유태 on 2017. 1. 8..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//


import UIKit

// App Theme 색상 지정.
extension UIColor {
    // adobe: #3FC1C4
    // Apple 0 184 185
    public class var themeColor : UIColor {
        return UIColor.init(red: 0/255, green: 184/255, blue: 185/255, alpha: 1.0)
    }
    public class var themeColors : [UIColor] {
        return [
            UIColor.init(red: 222/255, green: 252/255, blue: 255/255, alpha: 1.0),
            UIColor.init(red: 0/255, green: 183/255, blue: 168/255, alpha: 1.0),
            UIColor.init(red: 61/255, green: 149/255, blue: 199/255, alpha: 1.0)]
    }
}
