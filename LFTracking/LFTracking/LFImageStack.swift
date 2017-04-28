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
    @IBInspectable private var defaultImage: ImageIndex = ImageIndex(x: 7, y: 7, depth: nil)
    @IBInspectable private var moveUnit: Int = 20
    @IBInspectable private var angularResolution: CGSize = CGSize(width: 15, height: 15)
    @IBInspectable private var depthResolution: Int = 11

    private var baseImage: ImageIndex = ImageIndex()
    private var currentImage: ImageIndex = ImageIndex()
    private var nextImage: ImageIndex = ImageIndex()
    private var currentDepthMap: UIImage = UIImage(named: "Bike_depth") ?? UIImage()
    private var images: [UIImageView] = [UIImageView]()
    
    private var trackingFile: URL? = nil
    private var answersFile: URL? = nil
    
    private var previousTime: Date? = nil
    private var currentTime: Date? = nil
    
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupOutputFiles()
        setupImages()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        setupOutputFiles()
        setupImages()
    }
    
    //MARK: Gesture Handlers
    
    func touchImage(touchGesture: UITapGestureRecognizer){
        baseImage = currentImage
    }
    
    func moveImage(panGesture: UIPanGestureRecognizer) {
        
        let translation = panGesture.translation(in: self)
        
        let diffX = Int(-translation.x / CGFloat(moveUnit))
        let diffY = Int(-translation.y / CGFloat(moveUnit))
        
        let newImgX = clampInteger(Int(baseImage.x) + diffX, minimum: 0, maximum: Int(angularResolution.width) - 1)
        let newImgY = clampInteger(Int(baseImage.y) + diffY, minimum: 0, maximum: Int(angularResolution.height) - 1)
        nextImage = ImageIndex(x: newImgX, y: newImgY, depth: nil)
        
        if(nextImage != currentImage){
            displayImage(nextImage)
        }
        
    }
    
    func refocusImage(tapGesture: UITapGestureRecognizer){
        let tapPosition = tapGesture.location(in: tapGesture.view)
        let positionInImage = CGPoint(x: round(tapPosition.x * 4/3), y: round(tapPosition.y * 4/3))
        
        let depth = currentDepthMap.getPixelColorGrayscale(pos: positionInImage)
        let focusDepth = Int(round(depth * CGFloat(depthResolution-1)))
        
        refocusEffect(depth: focusDepth)
    }
    
    //MARK: Private Methods
    
    private func setupOutputFiles() {
        currentTime = Date()
        
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        // Setup tracking file
        let trackingFileName = "tracking"
        trackingFile = DocumentDirURL.appendingPathComponent(trackingFileName).appendingPathExtension("txt")
        write("", toFile: trackingFile)
        print("trackingFile path: \(trackingFile!.path)")
        
        // Setup answers file
        let answersFileName = "answers"
        answersFile = DocumentDirURL.appendingPathComponent(answersFileName).appendingPathExtension("txt")
        write("", toFile: answersFile)
        print("answersFile path: \(answersFile!.path)")
    }
    
    private func setupImages() {
        
        baseImage = defaultImage
        currentImage = defaultImage
        
        // Add two images to the stack
        for _ in 0..<2{
            
            let img = UIImageView()
            img.image = UIImage(named: getCurrentImageName())
            
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
            addArrangedSubview(img)
        }
        
    }
    
    private func write(_ string: String, toFile: URL?){
        if let fileURL = toFile {
            do {
                // Write to the file
                try string.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }
    }
    
    private func writeLine(_ string: String, toFile: URL?){
        if let fileURL = toFile {
            let fileHandle: FileHandle? = FileHandle(forUpdatingAtPath: fileURL.path)
            
            if fileHandle == nil {
                print("File open failed")
            } else {
                let data = (string+"\n" as NSString).data(using: String.Encoding.utf8.rawValue)
                fileHandle?.seekToEndOfFile()
                fileHandle?.write(data!)
                fileHandle?.closeFile()
            }
        }
    }
    
    // Display the image
    private func displayImage(_ imageToDisplay: ImageIndex) {
        closeCurrentImage()
        currentImage = imageToDisplay
        
        for img in images{
            img.image = UIImage(named: getCurrentImageName())
        }
    }
    
    private func closeCurrentImage() {
        previousTime = currentTime
        currentTime = Date()
        
        let currentImageName = getCurrentImageName()

        let onScreen = currentTime! - previousTime!.timeIntervalSince1970
        writeLine(currentImageName, toFile: trackingFile)
        print(onScreen)
    }
    
    private func refocusEffect(depth: Int) {
        if var currentDepth = currentImage.depth {
            
            currentDepth += (depth - currentDepth > 0 ? 1 : -1)
            
            moveFocus(depth: currentDepth)
            
            if currentDepth != depth {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    self.refocusEffect(depth: depth)
                })
            }
            
        }else {
            moveFocus(depth: depth)
        }
        
    }
    
    private func moveFocus(depth: Int) {
        nextImage = ImageIndex(x: defaultImage.x, y: defaultImage.y, depth: depth)
        
        displayImage(nextImage)
    }
    
    private func getCurrentImageName() -> String {
        var imageName = ""
        
        if let depth = currentImage.depth {
            // if currentImage.depth is defined, use the refocused images
            imageName = String(format: "Bikes/%03d_%03d_%03d", Int(currentImage.x), Int(currentImage.y), depth)
        }else {
            // Otherwise the standard images
            imageName = String(format: "Bikes/%03d_%03d", Int(currentImage.x), Int(currentImage.y))
        }
        
        return imageName
    }
    
    private func clampInteger(_ x: Int, minimum: Int, maximum: Int) -> Int {
        precondition(minimum <= maximum, "minimum greater than maximum")
        
        return max(minimum, min(maximum, x))
    }

}


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
