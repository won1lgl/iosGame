//
//  StartMenuScene.swift
//  shootingGame
//
//  Created by Mac on 2019/11/28.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import SpriteKit

class StartMenuScene: SKScene {
    
}

extension StartMenuScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            //play sound
            Audio.sharedInstance.playSound(soundFileName: Sound.hit.fileName)

            //go to the next scene
            if let node = self.atPoint(location) as? SKSpriteNode {
                if node.name == "startButton" {
                    if let scene = SKScene(fileNamed: "StageScene"){
                        scene.scaleMode = .aspectFit
                        self.view?.presentScene(scene)
                    }
                }
            }
            
            //add node
            let shot = SKSpriteNode(imageNamed: Texture.shotBlue.imageName)
            shot.position = location
            shot.zPosition = 10
            shot.xScale = 1.4
            shot.yScale = 1.4
            self.addChild(shot)
            
        }
    }
}
