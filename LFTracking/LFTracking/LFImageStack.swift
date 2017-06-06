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
    
    var imageName: String? = nil

    @IBInspectable private var imageSize: CGSize = CGSize(width: 469.5, height: 325.5)
    @IBInspectable private var defaultImage: SubapertureImage = SubapertureImage(x: 7, y: 7, depth: nil)
    @IBInspectable private var moveUnit: Int = 20
    @IBInspectable private var angularResolution: CGSize = CGSize(width: 15, height: 15)
    @IBInspectable private var depthResolution: Int = 11

    private var baseImage: SubapertureImage = SubapertureImage()
    private var currentImage: SubapertureImage = SubapertureImage()
    private var nextImage: SubapertureImage = SubapertureImage()
    private var depthMap: UIImage! = nil
    private var images: [UIImageView] = [UIImageView]()
    
    private var previousTime: Date? = nil
    private var currentTime: Date? = nil
    private let dateFormatter = DateFormatter()
    
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImages()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        setupImages()
    }
    
    //MARK: Public Methods
    
    // Initializes the LFImageStack with the name of the first image to display
    func initWithImageName(_ imageName: String) {
        currentTime = Date()
        setNewImageName(imageName)
    }
    
    // Perform actions necessary when an image is replaced by another
    func closeCurrentImage() {
        previousTime = currentTime
        currentTime = Date()
        
        if previousTime != nil {
            let currentImageName = getCurrentImagePath()
            let onScreen = stringFromTimeInterval(currentTime!.timeIntervalSince(previousTime!))
            let start = dateFormatter.string(from: previousTime!)
            let end = dateFormatter.string(from: currentTime!)
            
            let toWrite = "\(currentImageName)  start: \(start)  end: \(end)  on-screen: \(onScreen)"
            
            ViewController.writeLine(toWrite, toFile: ViewController.trackingFile)
        }
    }
    
    //MARK: Gesture Handlers
    
    // Called when the user touches one of the images
    func touchImage(touchGesture: UITapGestureRecognizer){
        baseImage = currentImage
    }
    
    // Called when the user moves his finger while touching the image
    func moveImage(panGesture: UIPanGestureRecognizer) {
        
        let translation = panGesture.translation(in: self)
        
        let diffX = Int(-translation.x / CGFloat(moveUnit))
        let diffY = Int(-translation.y / CGFloat(moveUnit))
        
        let newImgX = clampInteger(Int(baseImage.x) + diffX, minimum: 0, maximum: Int(angularResolution.width) - 1)
        let newImgY = clampInteger(Int(baseImage.y) + diffY, minimum: 0, maximum: Int(angularResolution.height) - 1)
        nextImage = SubapertureImage(x: newImgX, y: newImgY, depth: nil)
        
        updateImage(nextImage)
        
    }
    
    // Called whe the user double-taps on on of the images
    func refocusImage(tapGesture: UITapGestureRecognizer){
        if let depthMapImage = depthMap {
            
            let tapPosition = tapGesture.location(in: tapGesture.view)
            let positionInImage = CGPoint(x: round(tapPosition.x * 4/3), y: round(tapPosition.y * 4/3))
            
            let depth = depthMapImage.getPixelColorGrayscale(pos: positionInImage)
            let focusDepth = Int(round(depth * CGFloat(depthResolution-1)))
            
            refocusEffect(depth: focusDepth)
        }
    }
    
    //MARK: Private Methods
    
    func setNewImageName(_ newImageName: String){
        imageName = newImageName
        depthMap = UIImage(named: "depth_map/\(imageName!)")
        displayImage(defaultImage)
    }
    
    // Set up the GUI needed to display the side-by-side images
    private func setupImages() {
        
        baseImage = defaultImage
        dateFormatter.dateFormat = "HH:mm:ss.SSSSSS"
        
        // Title displayed on top of the images
        let imageTitle = ["Test", "Reference"]
        
        // Add two images to the stack
        for i in 0..<2{
            
            let myBundle = Bundle(for: type(of: self))
            let img = UIImageView()
            img.image = UIImage(named: getCurrentImagePath(), in: myBundle, compatibleWith: self.traitCollection)
            
            img.isUserInteractionEnabled = true
            
            // Add constraints
            img.translatesAutoresizingMaskIntoConstraints = false
            img.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
            img.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
            
            // Add touch gesture recognizer
            let touchGesture = TouchDownGestureRecognizer(target: self, action:#selector(LFImageStack.touchImage(touchGesture:)))
            img.addGestureRecognizer(touchGesture)
            
            // Add pan gesture recognizer
            let panGesture = UIPanGestureRecognizer(target: self, action:#selector(LFImageStack.moveImage(panGesture:)))
            img.addGestureRecognizer(panGesture)
            
            // Add double tap gesture recognizer (for refocusing)
            let doubleTapGesture = UITapGestureRecognizer(target: self, action:#selector(LFImageStack.refocusImage(tapGesture:)))
            doubleTapGesture.numberOfTapsRequired = 2
            img.addGestureRecognizer(doubleTapGesture)
            
            images.append(img)
            
            // Label for the image title
            let imageTitleLabel = UILabel()
            imageTitleLabel.text = imageTitle[i]
            imageTitleLabel.font = UIFont(name: imageTitleLabel.font.fontName, size: 14)
            imageTitleLabel.textAlignment = .center
            
            imageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageTitleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
            
            
            // Create a vertical stack for to put the image and its title
            let verticalStack = UIStackView()
            verticalStack.axis = .vertical
            verticalStack.addArrangedSubview(imageTitleLabel)
            verticalStack.addArrangedSubview(img)
            
            addArrangedSubview(verticalStack)
        }
        
    }
    
    // Display the given image if it is different from the current one
    private func updateImage(_ newImage: SubapertureImage) {
        if newImage != currentImage {
            closeCurrentImage()
            displayImage(newImage)
        }
        
    }
    
    // Display the given image
    private func displayImage(_ imageToDisplay: SubapertureImage) {
        currentImage = imageToDisplay
        
        for img in images{
            img.image = UIImage(named: getCurrentImagePath())
        }

    }
    
    // Animates the refocusing to the given depth in a smooth transition
    private func refocusEffect(depth: Int) {
        let timePerImageSeconds = 0.02
        
        if var currentDepth = currentImage.depth {
            
            currentDepth += (depth - currentDepth > 0 ? 1 : -1)
            
            moveFocus(depth: currentDepth)
            
            if currentDepth != depth {
                DispatchQueue.main.asyncAfter(deadline: .now() + timePerImageSeconds, execute: {
                    self.refocusEffect(depth: depth)
                })
            }
            
        }else {
            moveFocus(depth: depth)
        }
        
    }
    
    // Displays the image corresponding to the given focus depth
    private func moveFocus(depth: Int) {
        nextImage = SubapertureImage(x: defaultImage.x, y: defaultImage.y, depth: depth)
        
        updateImage(nextImage)
    }
    
    // Return the path of the current image
    private func getCurrentImagePath() -> String {
        var imagePath = ""
        
        if let imgName = imageName {
            if let depth = currentImage.depth {
                // if currentImage.depth is defined, use the refocused images
                imagePath = String(format: "%@/%03d_%03d_%03d", imgName, Int(currentImage.x), Int(currentImage.y), depth)
            }else {
                // Otherwise the standard images
                imagePath = String(format: "%@/%03d_%03d", imgName, Int(currentImage.x), Int(currentImage.y))
            }
        } else {
            // if the imageName is not set, put the default image
            imagePath = "default"
        }
        return imagePath
    }
    
    // Clamp the integer x between the given minimum and maximum
    private func clampInteger(_ x: Int, minimum: Int, maximum: Int) -> Int {
        precondition(minimum <= maximum, "minimum greater than maximum")
        
        return max(minimum, min(maximum, x))
    }
    
    // Create a string corresponding to the given time interval
    private func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        
        let ti = NSInteger(interval)
        
        let microsec = Int((interval.truncatingRemainder(dividingBy: 1)) * 1000000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.6d",hours,minutes,seconds,microsec)
    }

}


extension UIImage {
    // Return the RGB color of the pixel that is at the given position
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
    
    // Return the value of the pixel of a grayscale image that is at the given position
    func getPixelColorGrayscale(pos: CGPoint) -> CGFloat {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 2
        
        let g = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        // alpha channel is not needed
        // let a = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        
        return g
    }
}
