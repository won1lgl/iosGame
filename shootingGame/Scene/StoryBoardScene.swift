//
//  StoryBoardScene.swift
//  shootingGame
//
//  Created by Mac on 2019/11/27.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import SpriteKit

class StoryBoardScene: SKScene {
    var duckScoreNode: SKNode!
    var targetScoreNode: SKNode!
    var manager: GameManager!
    
    override func didMove(to view: SKView) {
        manager = GameManager(scene: self)
        loadUI()
    }
    
    
}

//Load UI
extension StoryBoardScene {
    func loadUI() {
        //load score ui
        duckScoreNode = manager.generateTextNode(from: "2332")
        targetScoreNode = manager.generateTextNode(from: "140")
        duckScoreNode.position = CGPoint(x: 0, y: 40)
        targetScoreNode.position = CGPoint(x: 0, y: -58)
        addChild(duckScoreNode)
        addChild(targetScoreNode)
    }
}

//Touches
extension StoryBoardScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            //play sound
            Audio.sharedInstance.playSound(soundFileName: Sound.hit.fileName)

            //go to the next scene
            if let node = self.atPoint(location) as? SKSpriteNode {
                if node.name == "restart" {
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
