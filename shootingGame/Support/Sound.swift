//
//  Sound.swift
//  shootingGame
//
//  Created by Mac on 2019/11/27.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation

enum Sound: String {
    case musicLoop = "Cheerful Annoyance.wav"
    case hit = "hit.wav"
    case reload = "reload.wav"
    case score = "score.wav"
    
    var fileName: String {
        return rawValue
    }
}
