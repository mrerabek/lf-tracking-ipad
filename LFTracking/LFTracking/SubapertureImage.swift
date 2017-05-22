//
//  SubapertureImage.swift
//  LFTracking
//
//  Created by Tanguy Albrici on 25.04.17.
//  Copyright © 2017 Tanguy Albrici. All rights reserved.
//

import Foundation

class SubapertureImage: Equatable {
    
    public var x: Int
    public var y: Int
    public var depth: Int?
    
    public init() {
        self.x = 0
        self.y = 0
        self.depth = nil
    }
    
    public init(x: Int, y: Int, depth: Int?) {
        self.x = x
        self.y = y
        self.depth = depth
    }
    
    static func == (lhs: SubapertureImage, rhs: SubapertureImage) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.depth == rhs.depth
    }
    
}
