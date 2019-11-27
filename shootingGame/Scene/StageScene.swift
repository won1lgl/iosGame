//
//  StageScene.swift
//  shootingGame
//
//  Created by Mac on 2019/11/13.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class StageScene: SKScene {
    
    //Node
    var rifle: SKSpriteNode?
    var crosshair: SKSpriteNode?
    var fire = FireButton()
    var duckScoreNode: SKNode!
    var targetScoreNode: SKNode!
    
    var magzine: Magzine!
        
    //Touches
    var selectedNodes: [UITouch: SKSpriteNode] = [:]
    
    var touchDifferent: (CGFloat, CGFloat)?
    
    //Game logic
    var manager: GameManager!
    
    //GameState Machine
    
    var gameStateMachine: GKStateMachine!
    
    //custom the scene
    override func didMove(to view: SKView) {
        manager = GameManager(scene: self)
        
        loadUI()
        
        Audio.sharedInstance.playSound(soundFileName: Sound.musicLoop.fileName)
        Audio.sharedInstance.player(with: Sound.musicLoop.fileName)?.volume = 0.3
        Audio.sharedInstance.player(with: Sound.musicLoop.fileName)?.numberOfLoops = -1
        
        gameStateMachine = GKStateMachine(states: [
            ReadyState(fire: fire, magzine: magzine),
            ShootingState(fire: fire, magzine: magzine),
            ReloadingState(fire: fire, magzine: magzine)
        ])
        
        gameStateMachine.enter(ReadyState.self)
        
        manager.activeDucks()
        manager.activeTargets()
    }
}

//MARK: -gameLoop
extension StageScene {
    override func update(_ currentTime: TimeInterval) {
        syncRiflePosition()
        setBoundry()
    }
}

//MARK: -Touches
extension StageScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let crosshair = crosshair else {
            return
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            if let node = self.atPoint(location) as? SKSpriteNode {
                if !selectedNodes.values.contains(crosshair) && !(node is FireButton){
                    selectedNodes[touch] = crosshair
                    let xDifference = touch.location(in: self).x - crosshair.position.x
                    let yDifference = touch.location(in: self).y - crosshair.position.y
                    touchDifferent = (xDifference, yDifference)
                }
                
                //actual shooting
                if node is FireButton {
                    selectedNodes[touch] = fire
                    
                    if !fire.isReloading{
                        fire.isPressed = true
                        magzine.shoot()
                        
                        //Play Sound
                        Audio.sharedInstance.playSound(soundFileName: Sound.hit.fileName)
                        
                        
                        if magzine.needToReload() {
                            gameStateMachine.enter(ReloadingState.self)
                        }
                        
                        //find shoot Node
                        let shootNode = manager.findShootNode(at: crosshair.position)
                        
                        guard let (scoreText, shotImageName) = manager.findTextAndImageName(for: shootNode.name) else {
                            return
                        }
                        //add shot image
                        manager.addShot(imageNamed: shotImageName, to: shootNode, on: crosshair.position)
                        //add score
                        manager.addTextNode(on: crosshair.position, from: scoreText)
                        //play score sound
                        Audio.sharedInstance.playSound(soundFileName: Sound.score.fileName)
                        //update score node
                        manager.updateScore(text: String(manager.duckCount * manager.duckScore), node: &duckScoreNode)
                        manager.updateScore(text: String(manager.targetCount * manager.targetScore), node: &targetScoreNode)
                        //animate shoot node
                        shootNode.physicsBody = nil
                        if let node = shootNode.parent {
                            node.run(.sequence([
                                .wait(forDuration: 0.2),
                                .scaleY(to: 0, duration: 0.2)
                            ]))
                        }
                    }
                }
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let crosshair = crosshair else {
            return
        }
        guard let touchDifferent = touchDifferent else {
            return
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            if let node = selectedNodes[touch] {
                if node.name == "fire" {
                    
                } else {
                    let newCrosshairPosition = CGPoint(x: location.x - touchDifferent.0, y: location.y - touchDifferent.1)
                    
                    crosshair.position = newCrosshairPosition
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if selectedNodes[touch] !== nil {
                if let fire = selectedNodes[touch] as? FireButton {
                    fire.isPressed = false
                }
                selectedNodes[touch] = nil
            }
        }
    }
    
}

//MARK: -Action
//!!extension means add more function in a type
extension StageScene {
    
    func loadUI () {
        if let scene = scene {
            //rifle and crosshair
            rifle = childNode(withName: "rifle") as? SKSpriteNode
            crosshair = childNode(withName: "crosshair") as? SKSpriteNode
            crosshair?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        }
        
        //add fire button
        fire.position = CGPoint(x: 720, y: 80)
        fire.xScale = 1.7
        fire.yScale = 1.7
        fire.zPosition = 11
        
        addChild(fire)
        
        //Add icons
        let duckIcon = SKSpriteNode(imageNamed: Texture.duckIcon.imageName)
        duckIcon.position = CGPoint(x: 36, y: 365)
        duckIcon.zPosition = 11
        addChild(duckIcon)
        
        let targetIcon = SKSpriteNode(imageNamed: Texture.targetIcon.imageName)
        targetIcon.position = CGPoint(x: 36, y: 325)
        targetIcon.zPosition = 11
        addChild(targetIcon)
        
        //Add score node
        duckScoreNode = manager.generateTextNode(from: "0")
        duckScoreNode.position = CGPoint(x: 60, y: 365)
        duckScoreNode.zPosition = 11
        duckScoreNode.xScale = 0.5
        duckScoreNode.yScale = 0.5
        addChild(duckScoreNode)
        
        targetScoreNode = manager.generateTextNode(from: "0")
        targetScoreNode.position = CGPoint(x: 60, y: 325)
        targetScoreNode.zPosition = 11
        targetScoreNode.xScale = 0.5
        targetScoreNode.yScale = 0.5
        addChild(targetScoreNode)
        
        //Add empty magzine
        let magzineNode = SKNode()
        magzineNode.position = CGPoint(x: 760, y: 20)
        magzineNode.zPosition = 11
        
        var bullets = Array<Bullet>()
        for i in 0...manager.ammunitionQuantity - 1 {
            let bullet = Bullet()
            bullet.position = CGPoint(x: -30 * i, y: 0)
            bullets.append(bullet)
            magzineNode.addChild(bullet)
        }
        
        magzine = Magzine(bullets: bullets)
        addChild(magzineNode)
    }
    
    func syncRiflePosition() {
        guard let riffle = rifle else {
            return
        }
        guard let crosshair = crosshair else {
            return
        }
        
        riffle.position.x = crosshair.position.x + 100
    }
    
    func setBoundry() {
        guard let scene = scene else {
            return
        }
        guard let crosshair = crosshair else {
            return
        }
        
        if crosshair.position.x < scene.frame.minX {
            crosshair.position.x = scene.frame.minX
        }
        
        if crosshair.position.x > scene.frame.maxX {
            crosshair.position.x = scene.frame.maxX
        }
        
        if crosshair.position.y < scene.frame.minY {
            crosshair.position.y = scene.frame.minY
        }
        
        if crosshair.position.y > scene.frame.maxY {
            crosshair.position.y = scene.frame.maxY
        }
    }
}
