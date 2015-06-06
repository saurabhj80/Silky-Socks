//
//  SJColorFontCollectionViewCell.swift
//  Silky Socks
//
//  Created by Saurabh Jain on 6/5/15.
//  Copyright (c) 2015 Full Stak. All rights reserved.
//

import UIKit

class SJColorFontCollectionViewCell: UICollectionViewCell {
    
    var text: String? {
        didSet {
            textLabel?.text = text
        }
    }
    
    var font: UIFont? {
        didSet {
            textLabel?.font = font
        }
    }
    
    private var textLabel: UILabel?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    
    private func initialSetup() {
        
        textLabel = UILabel(frame: bounds)
        textLabel?.textColor = UIColor.whiteColor()
        textLabel?.textAlignment = .Center
        addSubview(textLabel!)
        pinSubviewToView(subView: textLabel!)
    }
    
}
