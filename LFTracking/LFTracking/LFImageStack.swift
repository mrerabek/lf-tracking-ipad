//
//  LFImageStack.swift
//  LFTracking
//
//  Created by Tanguy Albrici on 21.04.17.
//  Copyright © 2017 Tanguy Albrici. All rights reserved.
//

import UIKit

@IBDesignable class LFImageStack: UIStackView, UIGestureRecognizerDelegate {
    
    //MARK: Properties
    
    @IBInspectable private var imageSize: CGSize = CGSize(width: 469.5, height: 325.5)
    @IBInspectable private var defaultImage: CGPoint = CGPoint(x: 7, y: 7)
    @IBInspectable private var moveUnit: Int = 30
    private var tapPosition: CGPoint = CGPoint()
    private var baseImage: CGPoint = CGPoint()
    private var currentImage: CGPoint = CGPoint()
    private var nextImage: CGPoint = CGPoint()
    private var images: [UIImageView] = [UIImageView]()

    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        baseImage = defaultImage
        currentImage = defaultImage
        print(currentImage)
        setupImages()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        baseImage = defaultImage
        currentImage = defaultImage
        print(currentImage)
        setupImages()
    }
    
    //MARK: Private Methods
    
    private func setupImages() {
        
        // Add two images to the stack
        for _ in 0..<2{
            
            let img = UIImageView()
            
            img.image = UIImage(named: getCurrentImageName())
            img.isUserInteractionEnabled = true
            
            // Add constraints
            img.translatesAutoresizingMaskIntoConstraints = false
            img.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
            img.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
            
            // Add pan gesture recognizer
            let panGesture = UIPanGestureRecognizer(target: self, action:#selector(LFImageStack.panImage(panGesture:)))
            img.addGestureRecognizer(panGesture)
            
            // Add tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: self, action:#selector(LFImageStack.tapImage(tapGesture:)))
            img.addGestureRecognizer(tapGesture)
            
            images.append(img)
            addArrangedSubview(img)
        }
        
    }
    
    @objc private func tapImage(tapGesture: UITapGestureRecognizer){
        print("tap")
        baseImage = currentImage
        tapPosition = tapGesture.location(in: self)
    }
    
    @objc private func panImage(panGesture: UIPanGestureRecognizer) {

        //let newImage = UIImage(named: "Bikes/000_007")
        let translation = panGesture.translation(in: self)
        
        let diffX = Int(-translation.x / CGFloat(moveUnit))
        let diffY = Int(-translation.y / CGFloat(moveUnit))
        
        let newImgX = clampInteger(Int(baseImage.x) + diffX, minimum: 0, maximum: 14)
        let newImgY = clampInteger(Int(baseImage.y) + diffY, minimum: 0, maximum: 14)
        nextImage = CGPoint(x: newImgX, y: newImgY)
        
        if(nextImage != currentImage){
            //print(String(format: "(%02d, %02d)", diffX, diffY))
            
            currentImage = nextImage
            
            print(currentImage)
            
            for img in images{
                img.image = UIImage(named: getCurrentImageName())
            }
        }
        
    }
    
    private func getCurrentImageName() -> String {
        let imageName = String(format: "Bikes/%03d_%03d", Int(currentImage.x), Int(currentImage.y))
        return imageName
    }
    
    private func clampInteger(_ x: Int, minimum: Int, maximum: Int) -> Int {
        precondition(minimum <= maximum, "minimum greater than maximum")
        
        return max(minimum, min(maximum, x))
    }

}
