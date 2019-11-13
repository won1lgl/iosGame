//
//  Duck.swift
//  shootingGame
//
//  Created by Mac on 2019/11/13.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import SpriteKit

class Duck: SKNode {
    var hasTarget: Bool!
    init(hasTarget: Bool = false) {
        super.init()
        self.hasTarget = hasTarget
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
