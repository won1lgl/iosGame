//
//  Magzine.swift
//  shootingGame
//
//  Created by Mac on 2019/11/14.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import SpriteKit

class Magzine {
    var bullets: [Bullet]!
    var capacity: Int
    
    init(bullets: [Bullet]) {
        self.bullets = bullets
        self.capacity = bullets.count
    }
    
    //Action
    func shoot() {
        bullets.first { $0.wasShot() == false}?.shoot()
    }
    
    func needToReload() -> Bool {
        return bullets.allSatisfy { $0.wasShot() == true}
    }
    
    func reloadIfNeeded() {
        if needToReload(){
            for bullet in bullets {
                bullet.reloadIfNeeded()
            }
        }
    }
}
