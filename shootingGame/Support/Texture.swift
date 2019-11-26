//
//  Texture.swift
//  shootingGame
//
//  Created by Mac on 2019/11/14.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation

enum Texture: String {
    case fireButtonNormal = "fire_normal"
    case fireButtonPressed = "fire_pressed"
    case fireButtonReloading = "fire_reloading"
    case bulletEmptyTexture = "icon_bullet_empty"
    case bulletTexture = "icon_bullet"
    case shotBlue = "shot_blue"
    case shotBrown = "shot_brown"
    case duckIcon = "icon_duck"
    case targetIcon = "icon_target"
    
    var imageName: String {
        return rawValue
    }
    
}
