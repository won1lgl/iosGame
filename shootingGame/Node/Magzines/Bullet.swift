//
//  Bullet.swift
//  shootingGame
//
//  Created by Mac on 2019/11/14.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet: SKSpriteNode {
    
    private var isEmpty = true
    
    init() {
        let texture = SKTexture(imageNamed: Texture.bulletEmptyTexture.imageName)
        
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Action
    func reloaded() {
        isEmpty = false
    }
    
    func shoot() {
        isEmpty = true
        texture = SKTexture(imageNamed: Texture.bulletEmptyTexture.imageName)
    }
    
    //judge
    func wasShot() -> Bool {
        return isEmpty
    }
    
    func reloadIfNeeded() {
        if isEmpty {
            texture = SKTexture(imageNamed: Texture.bulletTexture.imageName)
            isEmpty = false
        }
    }
    
}
