//
//  TouchDownGestureRecognizer.swift
//  LFTracking
//
//  Created by Tanguy Albrici on 22.04.17.
//  Copyright © 2017 Tanguy Albrici. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class TouchDownGestureRecognizer: UIGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.state = .recognized
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
    
    // The touchdown gesture should not prevent a pan gesture or a tap gesture
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}
