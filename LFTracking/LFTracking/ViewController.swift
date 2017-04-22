//
//  ViewController.swift
//  LFTracking
//
//  Created by Tanguy Albrici on 21.04.17.
//  Copyright © 2017 Tanguy Albrici. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: Properties
    //@IBOutlet weak var imageStack: UIStackView!
    //@IBInspectable var imageSize: CGSize = CGSize(width: 469.5, height: 325.5)
    
    //MARK: Attributes
//    private var images: [UIImageView] = [UIImageView]()
//    private var currentImage: CGPoint = CGPoint(x: 7, y: 7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Actions
//    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
//        print("panGesture")
//        image.image = UIImage(named: "Bikes/000_007")
//    }
    
//    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
//        print("panGesture")
//        
//        let translation = sender.translation(in: self.view)
//        imageStack.moveImage(translation: translation)
//        
//        sender.setTranslation(CGPoint(x: 0,y :0), in: self.view)
//    }
    
//    private func setupImages() {
//        
//        // Add two image to the stack
//        for _ in 0..<2{
//            
//            let img = UIImageView()
//            img.image = UIImage(named: "Bikes/007_007")
//            img.isUserInteractionEnabled = true
//            
//            // Add constraints
//            img.translatesAutoresizingMaskIntoConstraints = false
//            img.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
//            img.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
//            
//            // Add recognizer
//            let recognizer = UIPanGestureRecognizer(target: self, action:#selector(ViewController.moveImage(recognizer:)))
//            recognizer.delegate = self
//            img.addGestureRecognizer(recognizer)
//            
//            images.append(img)
//            imageStack.addArrangedSubview(img)
//        }
//        
//    }
//    
//    func moveImage(recognizer: UIPanGestureRecognizer) {
//        print("moveImage")
//        let newImage = UIImage(named: "Bikes/000_007")
//        
//        for img in images{
//            img.image = newImage
//        }
//    }
    
}

