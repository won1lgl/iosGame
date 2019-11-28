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
    var duckScore: Int!
    var targetScore: Int!
    var highestHistoryScore: Int!
    var manager: GameManager!
    var userRepository = UserRepository()
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        manager = GameManager(scene: self)
        loadUI()
    }
    
    
}

//Load UI
extension StoryBoardScene {
    func loadUI() {
        //load ScoreBoard UI
        let scoreBoarBackGround = SKSpriteNode(imageNamed: "scoreBoard")
        scoreBoarBackGround.position = CGPoint(x: 0, y: -7)
        scoreBoarBackGround.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scoreBoarBackGround.xScale = 0.98
        addChild(scoreBoarBackGround)
        
        let restartNode = SKSpriteNode(imageNamed: "restart")
        restartNode.name = "restart"
        restartNode.position = CGPoint(x: 0, y: -142)
        addChild(restartNode)
        
        let duckIconNode = SKSpriteNode(imageNamed: "duck/1")
        duckIconNode.position = CGPoint(x: -79.446, y: 38.15)
        duckIconNode.xScale = 0.7
        duckIconNode.yScale = 0.7
        addChild(duckIconNode)
        
        let targetIconNode = SKSpriteNode(imageNamed: "targetForScoreBoard")
        targetIconNode.position = CGPoint(x: -81.646, y: -51.319)
        targetIconNode.xScale = 0.9
        targetIconNode.yScale = 0.9
        addChild(targetIconNode)
        
        let wood1 = SKSpriteNode(imageNamed: "bg_wood")
        wood1.position = CGPoint(x: -278, y: 72)
        addChild(wood1)
        
        let wood2 = SKSpriteNode(imageNamed: "bg_wood")
        wood2.position = CGPoint(x: -278, y: -72)
        addChild(wood2)
        
        let wood3 = SKSpriteNode(imageNamed: "bg_wood")
        wood3.position = CGPoint(x: 278, y: 72)
        addChild(wood3)
        
        let wood4 = SKSpriteNode(imageNamed: "bg_wood")
        wood4.position = CGPoint(x: 278, y: -72)
        addChild(wood4)
        
        //Load Score
        let duckScoreNode = manager.generateTextNode(from: String(duckScore))
        let targetScoreNode = manager.generateTextNode(from: String(targetScore))
        duckScoreNode.position = CGPoint(x: 0, y: 40)
        targetScoreNode.position = CGPoint(x: 0, y: -56)
        addChild(duckScoreNode)
        addChild(targetScoreNode)
        
        //Load New Sign If Needed
        let oldDuckHighestScore = userRepository.getScore(for: "duck")
        let oldTargetHighestScore = userRepository.getScore(for: "target")
        
        if duckScore > oldDuckHighestScore {
            userRepository.storageScore(score: duckScore, for: "duck")
            let new = SKSpriteNode(imageNamed: "new")
            new.position = CGPoint(x: -171, y: 37.3)
            addChild(new)
        }
        if targetScore > oldTargetHighestScore {
            userRepository.storageScore(score: targetScore, for: "target")
            let new = SKSpriteNode(imageNamed: "new")
            new.position = CGPoint(x: -171, y: -54.819)
            addChild(new)
        }
        
    }
}

//Touches
extension StoryBoardScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            //play sound
            Audio.sharedInstance.playSound(soundFileName: Sound.hit.fileName)
            Audio.sharedInstance.player(with: Sound.hit.fileName)?.volume = 0.5
            
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
