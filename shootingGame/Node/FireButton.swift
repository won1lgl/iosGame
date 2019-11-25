//
//  FireButton.swift
//  shootingGame
//
//  Created by Mac on 2019/11/14.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import SpriteKit

class FireButton: SKSpriteNode {
    var isReloading = false
    
    var isPressed: Bool = false {
        didSet {
            guard !isReloading else {return}
            if isPressed {
                texture = SKTexture(imageNamed: Texture.fireButtonPressed.imageName)
            } else {
                texture = SKTexture(imageNamed: Texture.fireButtonNormal.imageName)
            }
        }
    }
    
    init() {
        let texture = SKTexture(imageNamed: Texture.fireButtonNormal.imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
        
        name = "fire"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
