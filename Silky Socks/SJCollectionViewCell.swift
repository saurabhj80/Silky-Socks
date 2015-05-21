//
//  SJCollectionViewCell.swift
//  Silky Socks
//
//  Created by Kevin Koeller on 4/19/15.
//  Copyright (c) 2015 Full Stak. All rights reserved.
//

import UIKit

public let reuseIdentifier = "Cell"

class SJCollectionViewCell: UICollectionViewCell {

    // IBOutlets
    @IBOutlet weak var ss_imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // The Label
    var sj_label: SJLabel?

    // The pan gesture recognizer
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    // The pinch gesture recognizer
    private var pinchGestureRecognizer: UIPinchGestureRecognizer!
    
    // Used in pinch calculations
    private var lastScale: CGFloat = 0

    // Template object
    var template:Template? {
        didSet {
            if let template = template {
                ss_imgView?.image = template.image
                nameLabel.text = template.caption
            }
        }
    }
    
    // Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing.FlexibleHeight | .FlexibleWidth
        setTranslatesAutoresizingMaskIntoConstraints(false)
        clipsToBounds = true
        
        // Pan
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(panGestureRecognizer)
        
        // Pinch
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        pinchGestureRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(pinchGestureRecognizer)
    }
    
    // Add the label as a subview of boundingRectView
    // Is a view around the image because the image is smaller than the image view
    private var boundingRectView: UIView?
    
    // Aspect Fit
    private func addClipRect() {
        
        if let view = boundingRectView {
            view.removeFromSuperview()
            boundingRectView = nil
        }
        
        let aspectRatio = template!.image.size
        var boundingSize = ss_imgView.frame.size
        
        let mW = boundingSize.width / aspectRatio.width;
        let mH = boundingSize.height / aspectRatio.height;
        if mH < mW {
            boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width
        } else if mW < mH {
            boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height
        }
        
        let x = (ss_imgView.frame.width - boundingSize.width)/2
        let y = (ss_imgView.frame.height - boundingSize.height)/2 + 20
        let frame = CGRectMake(x, y, boundingSize.width, boundingSize.height)
        boundingRectView = UIView(frame: frame)
        boundingRectView!.clipsToBounds = true
        addSubview(boundingRectView!)
    }
    
    // Apply Layout Attributes
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        if let attr = layoutAttributes {
            self.frame = attr.frame
        }
    }
    
    // Create the text label
    func createLabel(text: String, font: UIFont) {
        
        // Create and add the bounding rect
        addClipRect()
        
        let midX = CGRectGetMidX(bounds)
        let midY = CGRectGetMidY(bounds)
        
        sj_label = SJLabel()
        sj_label!.text = text
        sj_label!.font = font
        sj_label!.sizeToFit()
        sj_label!.center = CGPoint(x: midX, y: midY)
        
        // Add subview
        boundingRectView?.addSubview(sj_label!)
    }
    
}

// MARK: Gesture Support
extension SJCollectionViewCell {
    
    // Handle Pan Gesture
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(self)
        if let sj_label = sj_label {
            if CGRectContainsPoint(sj_label.frame, location) {
                sj_label.center = location
            }
        }
    }
    
    // Handle Pinch
    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
        
        // Base Case
        if recognizer.numberOfTouches() != 2 {
            return
        }
        
        // Switching on the states
        switch recognizer.state {
            
            case .Began:
                    lastScale = recognizer.scale
                
            case .Changed:
                if let sj_label = sj_label {
                    
                    // Increasing font size
                    var fontSize = sj_label.font.pointSize
                    fontSize = ((recognizer.velocity > 0) ? 1 : -1) * 1 + fontSize;
                    
                    if (fontSize < 13) { fontSize = 13 }
                    if (fontSize > 80) { fontSize = 80 }

                    sj_label.font = UIFont(name: sj_label.font.fontName, size: fontSize)
                    
                    // Setting a new size for the frame and forcing it to re draw to get crisp text
                    let str: NSString = sj_label.text!
                    let size = str.boundingRectWithSize(CGSize(width: 400, height: CGFloat.max), options: NSStringDrawingOptions.UsesFontLeading | NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: sj_label.font], context: nil).size
                    sj_label.frame.size = size
                    
                }
                
            default:
                break
        }
    }
}
