//
//  SJCollectionViewCell.swift
//  Silky Socks
//
//  Created by Saurabh Jain on 4/19/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

import UIKit

// Cell Reuse identifier
public let reuseIdentifier = "Cell"

// MARK: SJCollectionViewCellDelegate
protocol SJCollectionViewCellDelegate: class {
    func collectionViewCell(cell: UICollectionViewCell, didSelectView view: UIView?, atPoint point: CGPoint)
    func collectionViewCell(cell: UICollectionViewCell, didTapInfoButton button: UIButton)
}

// MARK: SJCollectionViewCell Class
class SJCollectionViewCell: UICollectionViewCell {

    // IBOutlets
    @IBOutlet private(set) weak var ss_imgView: UIImageView! {
        didSet {
            ss_imgView?.backgroundColor = UIColor.whiteColor()
        }
    }
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var infoButton: UIButton!
    
    // Delegate
    weak var delegate: SJCollectionViewCellDelegate?
    
    // Array containing all the views added to the template
    private var sj_subViews = [UIView]()
    var sj_subviews_snap = [UIView]()
    
    // The number of the elements in the array
    var sj_subViews_count: Int {
        return sj_subViews.count
    }
    
    // Last selected view - Used in gestures
    private var lastSelectedView: UIView?
    private var lastSelectedSnapshotView: UIView?
    
    // The pan gesture recognizer
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    // The pinch gesture recognizer
    private var pinchGestureRecognizer: UIPinchGestureRecognizer!
    
    // The rotation gesture
    private var rotateGestureRecognizer: UIRotationGestureRecognizer!

    // The tap gesture
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    // Used in pan calculations
    private var firstX: CGFloat = 0
    private var firstY: CGFloat = 0
    
    // Used for keeping track of views in pan gesture
    private var selectedView: UIView?
    private var selectedSnapshotView: UIView?

    // Set containing the gesture - rotate and pinch
    private var activeRecognizers = NSMutableSet()
    
    // initial transform
    private var referenceTransform: CGAffineTransform?
    
    // Template object
    var template:Template? {
        didSet {
            if let template = template {
                ss_imgView?.image = template.image
                nameLabel.text = template.infoCaption
                
                // Set color
                if Static.sj_color != UIColor.clearColor() {
                    addColor(Static.sj_color)
                }
            }
        }
    }
    
    // static variable
    private struct Static {
        static var sj_color = UIColor.clearColor()
    }
        
    // Add the label as a subview of boundingRectView
    // Is a view around the image because the image is smaller than the image view
    private(set) var boundingRectView: UIView? { didSet { boundingRectView?.alpha = 0.9 } }
    
    var snapshotview: UIView? { didSet { snapshotview?.hidden = true } }
    
    // Masking that is applied to the boundingRectView
    private var maskImageView: UIImageView?
    
    // Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = [UIViewAutoresizing.FlexibleHeight, .FlexibleWidth]
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        // Pan
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(panGestureRecognizer)
        
        // Pinch
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handleGesture:")
        pinchGestureRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(pinchGestureRecognizer)
        
        // Rotate
        rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "handleGesture:")
        rotateGestureRecognizer.delaysTouchesBegan = true
        rotateGestureRecognizer.delegate = self
        addGestureRecognizer(rotateGestureRecognizer)
        
        // Tap
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGestureRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Can be called by instances to clean up
    func performCleanUp() {
        
        // No Color
        addColor(UIColor.clearColor())
        
        // Clean up
        cleanUp()
    }
    
    
    // Prepare for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanUp()
    }
    
    deinit {
        cleanUp()
        nameLabel = nil
        ss_imgView = nil
        template = nil
    }
    
    // Used for cleaning up the cell
    // Not to clear up the color when cleaning up
    private func cleanUp() {
        // Clear the subviews added to the cell
        for view in sj_subViews { view.removeFromSuperview() }
        for view in sj_subviews_snap { view.removeFromSuperview() }
        sj_subViews.removeAll(keepCapacity: true)
        sj_subviews_snap.removeAll(keepCapacity: true)
                
        if boundingRectView?.superview != nil { boundingRectView!.removeFromSuperview() }
        if maskImageView?.superview    != nil { maskImageView!.removeFromSuperview()    }
        if snapshotview?.superview     != nil { snapshotview!.removeFromSuperview()     }
        
        maskImageView = nil
        boundingRectView = nil
        snapshotview = nil
        
        // Tracking variables
        lastSelectedView = nil
        lastSelectedSnapshotView = nil
        activeRecognizers.removeAllObjects()
        referenceTransform = nil
        firstX = 0; firstY = 0
        
        // Gestures
        panGestureRecognizer = nil
        pinchGestureRecognizer = nil
        rotateGestureRecognizer = nil
    }
    
    // Apply Layout Attributes
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        frame = layoutAttributes.frame
    }
    
    // Returns the nib associated with the cell
    class func nib() -> UINib {
        return UINib(nibName: "SJCollectionViewCell", bundle: nil)
    }
    
    // Returns whether the collection view should pan or not
    func shouldPan() -> Bool {
        if sj_subViews_count > 0 || template!.image != ss_imgView.image {
            return false
        }
        return true
    }
}

// MARK: IBAction
extension SJCollectionViewCell {
    @IBAction func infoButtonPressed(sender: UIButton) {
        delegate?.collectionViewCell(self, didTapInfoButton: sender)
    }
}

// MARK: Customized Look
extension SJCollectionViewCell {
    
    // Add Bounding view
    private func addClipRect() {
        
        if let view = boundingRectView {
            view.removeFromSuperview()
            boundingRectView = nil
        }
        
        var size = UIImage.getBoundingSizeForAspectFit(template!.image.size, imageViewSize: ss_imgView.bounds.size)
        var point = CGPoint(x: CGRectGetMidX(ss_imgView.frame) - size.width/2, y: ss_imgView.frame.origin.y)
        var frame = CGRect(origin: point, size: size)
        
        // Alloc the bounding View
        boundingRectView = UIView(frame: frame)
        
        size.width = floor(size.width) + 20; size.height = floor(size.height) + 10
        point.y -= 5; point.x -= 10
        frame = CGRect(origin: point, size: size)
        
        // Black Normal
        if template?.index == 1 {
            size.height -= 120
            frame.size = size
        } else if template?.index == 2 { // Knee high
            size.height -= 50
            frame.size = size
        } else if template?.index == 5 { // Black tee
            size.height += 10
            size.width -= 100
            point.x += 50
            frame.size = size
            frame.origin = point
        }
        
        // Alloc snapshot view
        snapshotview = UIView(frame: frame)
        snapshotview?.clipsToBounds = true
        
        // Masking
        maskImageView = UIImageView(frame: boundingRectView!.bounds)
        maskImageView!.contentMode = .ScaleAspectFit
        maskImageView!.image = template?.maskImage ?? template?.image
        
        // Mask it
        boundingRectView!.maskView = maskImageView
        
        // Add Subview
        addSubview(boundingRectView!)
        addSubview(snapshotview!)
        sendSubviewToBack(snapshotview!)
    }
    
    // Create the text label
    func createLabel(text: String, font: UIFont, color: UIColor) {
        
        // Create and add the bounding rect
        if boundingRectView == nil {
            addClipRect()
        }
        
        // Create the text label
        let sj_label = SJLabel(frame: .zeroRect, text: text, font: font)
        sj_label.frame.size.width = CGRectGetWidth(boundingRectView!.frame)
        sj_label.textColor = color
        sj_label.sizeToFit()
        sj_label.center = CGPoint(x: boundingRectView!.center.x, y: boundingRectView!.center.y)
        
        // Add the label to the array of sub views
        sj_subViews.insert(sj_label, atIndex: 0)
        
        // Make sure that the last selected view
        // has a value
        lastSelectedView = sj_label
        
        // Add subview
        boundingRectView?.addSubview(sj_label)
        
        
        
        let sj_label_snap = SJLabel(frame: .zeroRect, text: text, font: font)
        sj_label_snap.frame.size.width = CGRectGetWidth(boundingRectView!.frame)
        sj_label_snap.textColor = color
        sj_label_snap.sizeToFit()
        sj_label_snap.center = CGPoint(x: boundingRectView!.center.x, y: boundingRectView!.center.y)
        
        // Add the label to the array of sub views
        sj_subviews_snap.insert(sj_label_snap, atIndex: 0)
        
        lastSelectedSnapshotView = sj_label_snap
        
        // Add subview
        snapshotview?.addSubview(sj_label_snap)
        
    }
    
    
    // Create Image
    func createImage(image: UIImage, forGrid: Bool) {
        
        // If grid then add image on the image
        if forGrid {
            let finishedImage = template!.image.drawImage(image, forTiling: true)
            ss_imgView.image = finishedImage
            
            // Create and add the bounding rect
            if boundingRectView == nil {
                addClipRect()
            }
            
            let sj_imgView_snap = UIImageView(frame: snapshotview!.bounds)
            sj_imgView_snap.contentMode = .ScaleAspectFill
            sj_imgView_snap.image = finishedImage
            
            // Add it to the array of subviews
            sj_subviews_snap.insert(sj_imgView_snap, atIndex: 0)
            
            // Make sure that the last selected view
            // has a value
            lastSelectedSnapshotView = sj_imgView_snap
            
            // Add subview
            snapshotview?.addSubview(sj_imgView_snap)

            return
        }
        
        func normalImage(image: UIImage) {
            
            // Create and add the bounding rect
            if boundingRectView == nil {
                addClipRect()
            }
            
            let size = UIImage.getBoundingSizeForAspectFit(template!.image.size, imageViewSize: ss_imgView.frame.size)
            var width = min(size.width, size.height)
            
            if template!.type == .Shirt {
                width -= 150
            }
            
            // Create the image
            let sj_imgView = UIImageView(frame: .zeroRect)
            sj_imgView.frame.size = CGSize(width: width, height: width)
            sj_imgView.center = CGPoint(x: boundingRectView!.center.x, y: boundingRectView!.center.y)
            sj_imgView.contentMode = .ScaleAspectFill
            sj_imgView.image = image
            
            // Add it to the array of subviews
            sj_subViews.insert(sj_imgView, atIndex: 0)
            
            // Make sure that the last selected view
            // has a value
            lastSelectedView = sj_imgView
            
            // Add subview
            boundingRectView?.addSubview(sj_imgView)
            
            
            // Create the image
            let sj_imgView_snap = UIImageView(frame: .zeroRect)
            sj_imgView_snap.frame.size = CGSize(width: width, height: width)
            sj_imgView_snap.center = CGPoint(x: boundingRectView!.center.x, y: boundingRectView!.center.y)
            sj_imgView_snap.contentMode = .ScaleAspectFill
            sj_imgView_snap.image = image
            
            // Add it to the array of subviews
            sj_subviews_snap.insert(sj_imgView_snap, atIndex: 0)
            
            // Make sure that the last selected view
            // has a value
            lastSelectedSnapshotView = sj_imgView_snap
            
            // Add subview
            snapshotview?.addSubview(sj_imgView_snap)
            
        }
        
        // add image on bounding view
        normalImage(image)
    }
    
    
    // Add Color to image
    func addColor(color: UIColor) {
        
        // Static Variable
        // Lot Better than saving in NSUserDefaults
        Static.sj_color = color
        
        if color == UIColor.clearColor() {
            ss_imgView.image = template?.image
            snapshotview?.backgroundColor = color
            return
        }
        
        // Add the color on the image itself rather than
        // placing the color on top the image
        // coz we need some kind of blending
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let image = self.template!.image.colorizeWith(color)
            dispatch_async(dispatch_get_main_queue()) {
                self.ss_imgView.image = image
            }
        }
        
        // Alternative
        if boundingRectView == nil {
            addClipRect()
        }
        snapshotview?.backgroundColor = color
    }
}

// MARK: Undo Support
extension SJCollectionViewCell {
    
    // Undo the grid
    func undoGrid() {
        ss_imgView.image = template?.image
        
        // If nothing exists, then
        if sj_subViews.count == 0 {
            cleanUp()
        }
    }
    
    // Undo - Label/Image
    func undo() {
        if sj_subViews.count > 0 {
            sj_subViews[0].removeFromSuperview()
            sj_subViews.removeAtIndex(0)
            sj_subviews_snap[0].removeFromSuperview()
            sj_subviews_snap.removeAtIndex(0)
            
            // If nothing exists, then
            if sj_subViews.count == 0 {
                cleanUp()
            }
        }
    }
    
    // Delete a view
    func undo(view: UIView) {
        for (index,subview) in sj_subViews.enumerate() {
            if subview == view {
                subview.removeFromSuperview()
                sj_subViews.removeAtIndex(index)
                sj_subviews_snap[index].removeFromSuperview()
                sj_subviews_snap.removeAtIndex(index)
            }
        }
        
        // If nothing exists, then
        if sj_subViews.count == 0 {
            cleanUp()
        }
    }
}

// MARK: Gesture Support
extension SJCollectionViewCell: UIGestureRecognizerDelegate {
    
    // Handle Tap
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(self)
        var selectedView: UIView?
        for (index, view) in sj_subViews.enumerate() {
            // Converting the sub view into the coordinate space of the cell from the bounding view
            let rect = convertRect(view.frame, fromView: boundingRectView)
            if CGRectContainsPoint(rect, location) {
                selectedView = view
                lastSelectedView = view
                selectedSnapshotView = sj_subviews_snap[index]
                lastSelectedSnapshotView = sj_subviews_snap[index]
            }
        }
        delegate?.collectionViewCell(self, didSelectView: selectedView, atPoint: location)
    }
    
    // Handle Pan Gesture
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        
        // Make sure that the bounding view exists
        if let boundingRectView = boundingRectView {
            
            // Find the location
            let location = recognizer.locationInView(self)
            let translatedpoint = recognizer.translationInView(self)
            
            switch recognizer.state {
                
                case .Began:
                    if recognizer.state == .Began {
                        
                        // Loop through the sub views array
                        loop: for (index, view) in sj_subViews.enumerate() {
                            
                            // If one subview contains the point
                            let rect = convertRect(view.frame, fromView: boundingRectView)
                            if CGRectContainsPoint(rect, location) {
                                selectedView = view
                                selectedSnapshotView = sj_subviews_snap[index]
                                break loop
                            }
                        }
                        
                        if selectedView != nil {
                            firstX = selectedView!.center.x
                            firstY = selectedView!.center.y
                        }
                    }
                    
                case .Changed:
                    if let view = selectedView {
                        view.center = CGPointMake(firstX + translatedpoint.x, firstY + translatedpoint.y)
                        selectedSnapshotView?.center = view.center
                    }
                
                case .Ended:
                        lastSelectedView = selectedView
                        lastSelectedSnapshotView = selectedSnapshotView
                
                default:
                    break
            }
        }
    }
    
    // Handle Rotate and Pinch Gesture
    @objc private func handleGesture(recognizer: UIGestureRecognizer) {
        
        // Make sure that the bounding view exists
        if let _ = boundingRectView {
            
            switch recognizer.state {
                case .Began:
                    if activeRecognizers.count == 0 {
                        referenceTransform = lastSelectedView?.transform
                    }
                    activeRecognizers.addObject(recognizer)
                    
                case .Ended:
                    referenceTransform = applyRecognizer(recognizer, toTransform: referenceTransform!)
                    activeRecognizers.removeObject(recognizer)
                    
                case .Changed:
                    var transform = referenceTransform
                    for gesture in activeRecognizers {
                        transform = applyRecognizer(gesture as! UIGestureRecognizer, toTransform: transform!)
                    }
                    lastSelectedView?.transform = transform!
                    lastSelectedSnapshotView?.transform = transform!
                    
                default:
                    break
            }
        }
    }
    
    // Helper Function
    private func applyRecognizer(recognizer: UIGestureRecognizer, toTransform transform:CGAffineTransform) -> CGAffineTransform {
        
        if recognizer.respondsToSelector("rotation") {
            return CGAffineTransformRotate(transform, (recognizer as! UIRotationGestureRecognizer).rotation)
        } else if recognizer.respondsToSelector("scale") {
            let scale = (recognizer as! UIPinchGestureRecognizer).scale
            return CGAffineTransformScale(transform, scale, scale)
        }
        
        return transform
        
    }
    
    // Important - Handle Pinch and rotate simultaneously
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
