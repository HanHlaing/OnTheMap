//
//  LoginButton.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 05/09/2021.
//

import Foundation
import UIKit

class CommomButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
        tintColor = UIColor.white
        backgroundColor = UIColor(named: "LoginButton")!
    }
    
}
