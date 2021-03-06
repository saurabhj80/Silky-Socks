//
//  SJCollectionViewDelegate.swift
//  Silky Socks
//
//  Created by Saurabh Jain on 5/16/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

import UIKit

protocol SJCollectionViewDelegate: UICollectionViewDelegate {
    
    // The Bottom Customization Button
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressCameraButton button:UIButton)
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressTextButton button:UIButton)
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressColorWheelButton button:UIButton)
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressGridButton button:UIButton)
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressQuestionButton button:UIButton)

    // Add To Cart
    func collectionView(collectionView: UICollectionView, didPressAddToCartButton button:UIButton, withCartImage cartImage: UIImage, generatedImage image: UIImage, andTemplate template: Template)
    
    // Restart
    func collectionView(collectionView: UICollectionView, didPressRestartButton button:UIButton)
    
    // Share
    func collectionView(collectionView: UICollectionView, didPressShareButton button: UIButton, withSnapShotImage snapshot: UIImage)
    
    // Tells the collection VC that a touch happened
    // Used for dismissing the color VC if it is visible
    func collectionView(collectionView: UICollectionView, touchesBegan point: CGPoint)
    
    // Tells that label/image was tapped in the collection view
    func collectionView(collectionView: UICollectionView, didTapSubview view: UIView)
    
    // Tells the collection view controller that the info button was tapped
    func collectionView(collectionView: UICollectionView, didTapInfoButton button: UIButton, withTemplateObject template: Template)
}