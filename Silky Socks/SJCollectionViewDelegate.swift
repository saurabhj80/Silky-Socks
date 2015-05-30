//
//  SJCollectionViewDelegate.swift
//  Silky Socks
//
//  Created by Saurabh Jain on 5/16/15.
//  Copyright (c) 2015 Full Stak. All rights reserved.
//

import UIKit

protocol SJCollectionViewDelegate: UICollectionViewDelegate {
    
    // The Bottom Customization Button
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressCameraButton button:UIButton)
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressTextButton button:UIButton)
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressColorWheelButton button:UIButton)
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressGridButton button:UIButton)
    func collectionView(collectionView: UICollectionView, bottomView: UIView , didPressSmileyButton button:UIButton)

    // Add To Cart
    func collectionView(collectionView: UICollectionView, didPressAddToCartButton button:UIButton, withSnapShotImage snapshot: UIImage, andTemplate template: Template)
    // Restart
    func collectionView(collectionView: UICollectionView, didPressRestartButton button:UIButton)
    
    // Tells the collection VC that a touch happened
    // Used for dismissing the color VC if it is visible
    func collectionView(collectionView: UICollectionView, touchesBegan touch: UITouch)
}