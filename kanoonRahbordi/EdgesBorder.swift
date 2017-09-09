//
//  EdgesBorder.swift
//  kanoonRahbordi
//
//  Created by negar on 96/Mordad/19 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        
        border.frame = CGRect(x:0,y: 0, width: self.frame.size.width , height: width)
        
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0, y:self.frame.size.height - width, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
}
