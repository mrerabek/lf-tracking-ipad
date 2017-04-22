//
//  ViewController.swift
//  LFTracking
//
//  Created by Tanguy Albrici on 21.04.17.
//  Copyright © 2017 Tanguy Albrici. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var imageStack: LFImage!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        print("panGesture")
        image.image = UIImage(named: "Bikes/000_007")
    }
    
//    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
//        print("panGesture")
//        
//        let translation = sender.translation(in: self.view)
//        imageStack.moveImage(translation: translation)
//        
//        sender.setTranslation(CGPoint(x: 0,y :0), in: self.view)
//    }
    
}

