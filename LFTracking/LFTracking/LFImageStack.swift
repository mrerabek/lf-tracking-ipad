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
    @IBInspectable private var moveUnit: Int = 20
    @IBInspectable private var angularResolution: CGSize = CGSize(width: 15, height: 15)

    private var baseImage: CGPoint = CGPoint()
    private var currentImage: CGPoint = CGPoint()
    private var nextImage: CGPoint = CGPoint()
    private var currentDepthMap: UIImage = UIImage(named: "Bike_depth") ?? UIImage()
    private var images: [UIImageView] = [UIImageView]()

    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImages()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        setupImages()
    }
    
    //MARK: Gesture Handlers
    
    func touchImage(touchGesture: UITapGestureRecognizer){
        baseImage = currentImage
    }
    
    func panImage(panGesture: UIPanGestureRecognizer) {
        
        let translation = panGesture.translation(in: self)
        
        let diffX = Int(-translation.x / CGFloat(moveUnit))
        let diffY = Int(-translation.y / CGFloat(moveUnit))
        
        let newImgX = clampInteger(Int(baseImage.x) + diffX, minimum: 0, maximum: Int(angularResolution.width) - 1)
        let newImgY = clampInteger(Int(baseImage.y) + diffY, minimum: 0, maximum: Int(angularResolution.height) - 1)
        nextImage = CGPoint(x: newImgX, y: newImgY)
        
        if(nextImage != currentImage){
            displayNextImage()
        }
        
    }
    
    func doubleTapImage(tapGesture: UITapGestureRecognizer){
        let tapPosition = tapGesture.location(in: tapGesture.view)
        let positionInImage = CGPoint(x: round(tapPosition.x * 4/3), y: round(tapPosition.y * 4/3))
        print(positionInImage)
        
        let depth = currentDepthMap.getPixelColorGrayscale(pos: positionInImage)
        let color = images[0].image!.getPixelColor(pos: positionInImage)
        print("depth : "+depth.description)
        print("color : "+color.description)
    }
    
    //MARK: Private Methods
    
    private func setupImages() {
        
        baseImage = defaultImage
        currentImage = defaultImage
        
        // Add two images to the stack
        for _ in 0..<2{
            
            let img = UIImageView()
            img.image = UIImage(named: getCurrentImageName())
           
//            if i%2==0 {
//                img.image = UIImage(named: getCurrentImageName())
//            }else{
//                img.image = currentDepthMap
//            }
            
            img.isUserInteractionEnabled = true
            
            // Add constraints
            img.translatesAutoresizingMaskIntoConstraints = false
            img.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
            img.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
            
            // Add touch gesture recognizer
            let touchGesture = TouchDownGestureRecognizer(target: self, action:#selector(LFImageStack.touchImage(touchGesture:)))
            img.addGestureRecognizer(touchGesture)
            
            // Add pan gesture recognizer
            let panGesture = UIPanGestureRecognizer(target: self, action:#selector(LFImageStack.panImage(panGesture:)))
            img.addGestureRecognizer(panGesture)
            
            // Add double tap gesture recognizer (for refocusing)
            let doubleTapGesture = UITapGestureRecognizer(target: self, action:#selector(LFImageStack.doubleTapImage(tapGesture:)))
            doubleTapGesture.numberOfTapsRequired = 2
            img.addGestureRecognizer(doubleTapGesture)
            
            images.append(img)
            addArrangedSubview(img)
        }
        
    }
    
    private func displayNextImage() {
        currentImage = nextImage
        
        for img in images{
            img.image = UIImage(named: getCurrentImageName())
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

//On the top of your swift
extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func getPixelColorGrayscale(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 2
        
        let g = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        
        return UIColor(red: g, green: g, blue: g, alpha: a)
    }
}
