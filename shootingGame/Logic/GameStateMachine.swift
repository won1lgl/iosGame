//
//  GameStateMachine.swift
//  shootingGame
//
//  Created by Mac on 2019/11/20.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import GameplayKit

class GameState: GKState{
    unowned var fire: FireButton
    unowned var magzine: Magzine
    
    init(fire: FireButton, magzine: Magzine) {
        self.fire = fire
        self.magzine = magzine
        
        super.init()
    }
}

class ReadyState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ShootingState.Type && !magzine.needToReload() {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        magzine.reloadIfNeeded()
        stateMachine?.enter(ShootingState.self)
    }
}

class ShootingState: GameState {
    
}

class ReloadingState: GameState {
    
}
