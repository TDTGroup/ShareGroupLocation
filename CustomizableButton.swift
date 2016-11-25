//
//  CustomizableButton.swift
//  ShareGroupLocation
//
//  Created by Khanh Trung on 11/22/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

@IBDesignable class CustomizableButton: UIButton {
    @IBInspectable var conerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = conerRadius
        }
    }
}
