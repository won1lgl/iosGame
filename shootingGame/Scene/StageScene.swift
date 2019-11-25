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
    
    var magzine: Magzine!
    
    //Touches
    var selectedNodes: [UITouch: SKSpriteNode] = [:]
    
    var duckMoveDuration: TimeInterval!
    
    let duckXPosition: [Int] = [160, 240, 320, 400, 480, 560, 640]
    var usingTargetsXPostion = Array<Int>()
    
    let ammunitionQuantity = 5
    
    var zPositionDecimal = 0.001 {
        didSet {
            if zPositionDecimal == 1 {
                zPositionDecimal = 0.001
            }
        }
    }
    
    var touchDifferent: (CGFloat, CGFloat)?
    
    //GameState Machine
    
    var gameStateMachine: GKStateMachine!
    
    //custom the scene
    override func didMove(to view: SKView) {
        loadUI()
        
        gameStateMachine = GKStateMachine(states: [
            ReadyState(fire: fire, magzine: magzine),
            ShootingState(fire: fire, magzine: magzine),
            ReloadingState(fire: fire, magzine: magzine)
        ])
        
        gameStateMachine.enter(ReadyState.self)
        
        activeDucks()
        activeTargets()
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
                        
                        if magzine.needToReload() {
                            gameStateMachine.enter(ReloadingState.self)
                        }
                        
                        //find shoot Node
                        let shootNode = findShootNode(at: crosshair.position)
                        //add shot image
                        addShot(imageNamed: "shot_blue", to: shootNode, on: crosshair.position)
                        //add score
                        
                        //update score node
                        
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
        
        //Add empty magzine
        let magzineNode = SKNode()
        magzineNode.position = CGPoint(x: 760, y: 20)
        magzineNode.zPosition = 11
        
        var bullets = Array<Bullet>()
        for i in 0...ammunitionQuantity - 1 {
            let bullet = Bullet()
            bullet.position = CGPoint(x: -30 * i, y: 0)
            bullets.append(bullet)
            magzineNode.addChild(bullet)
        }
        
        magzine = Magzine(bullets: bullets)
        addChild(magzineNode)
    }
    
    func generateDuck(hasTarget: Bool = false) -> Duck {
        var duck: SKSpriteNode
        var stick: SKSpriteNode
        let node = Duck(hasTarget: hasTarget)
        var duckImageName: String
        var duckNodeName: String
        var texture: SKTexture
        
        
        if hasTarget {
            duckImageName = "duck_target/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed: duckImageName)
            duckNodeName = "duck_target"
        } else {
            duckImageName = "duck/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed: duckImageName)
            duckNodeName = "duck"
        }
        
        duck = SKSpriteNode(texture: texture)
        duck.name = duckNodeName
        duck.position = CGPoint(x: 0, y: 140)
        
        let physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: texture.size())
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        duck.physicsBody = physicsBody
        
        stick = SKSpriteNode(imageNamed: "stick/\(Int.random(in: 1...2))")
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        
        duck.xScale = 0.8
        duck.yScale = 0.8
        stick.xScale = 0.8
        stick.yScale = 0.8
        
        node.addChild(stick)
        node.addChild(duck)
        
        return node
    }
    
    func generateTarget() -> Target {
        var target: SKSpriteNode
        var stick: SKSpriteNode
        let node = Target()
        let texture = SKTexture(imageNamed: "target/\(Int.random(in: 1...3))")
        
        target = SKSpriteNode(texture: texture)
        stick = SKSpriteNode(imageNamed: "stick_metal")
        
        target.xScale = 0.5
        target.yScale = 0.5
        target.position = CGPoint(x: 0, y: 95)
        target.name = "target"
        
        stick.xScale = 0.5
        stick.yScale = 0.5
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        
        node.addChild(stick)
        node.addChild(target)
        
        return node
    }
    
    func activeDucks() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){timer in
            let duck = self.generateDuck(hasTarget: Bool.random())
            duck.position = CGPoint(x: -10, y: Int.random(in: 60...90))
            duck.zPosition = Int.random(in: 0...1) == 0 ? 4 : 6
            duck.zPosition += CGFloat(self.zPositionDecimal)
            self.zPositionDecimal += 0.001
            
            self.scene?.addChild(duck)
            
            if duck.hasTarget {
                self.duckMoveDuration = TimeInterval(Int.random(in: 2...4))
            } else {
                self.duckMoveDuration = TimeInterval(Int.random(in: 5...7))
            }
            
            duck.run(.sequence([
                .moveTo(x: 850, duration: self.duckMoveDuration),
                .removeFromParent()]))
        }
    }
    
    func activeTargets() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true){timer in
            let target = self.generateTarget()
            var xPosition = self.duckXPosition.randomElement()!
            while self.usingTargetsXPostion.contains(xPosition) {
                xPosition = self.duckXPosition.randomElement()!
            }
            
            self.usingTargetsXPostion.append(xPosition)
            target.position = CGPoint(x: xPosition, y: Int.random(in: 120...145))
            target.zPosition = 1
            target.yScale = 0
            
            self.scene?.addChild(target)
            
            let physicsBody = SKPhysicsBody(circleOfRadius: 71/2)
            physicsBody.affectedByGravity = false
            physicsBody.isDynamic = false
            physicsBody.allowsRotation = false
            
            target.run(.sequence([
                .scaleY(to: 1, duration: 0.2),
                .run {
                    if let target = target.childNode(withName: "target") {
                        target.physicsBody = physicsBody
                    }
                    },
                .wait(forDuration: TimeInterval(Int.random(in: 3...4))),
                .scaleY(to: 0, duration: 0.2),
                .removeFromParent(),
                .run{
                    self.usingTargetsXPostion.remove(at: self.usingTargetsXPostion.firstIndex(of: xPosition)!)
                }]))
        }
    }
    
    func findShootNode(at position: CGPoint) -> SKSpriteNode {
        var shootNode = SKSpriteNode()
        var biggestZPosition: CGFloat = 0.0
        
        self.physicsWorld.enumerateBodies(at: position) { (body, pointer) in
            guard let node = body.node as? SKSpriteNode else {return}
            if node.name == "duck" || node.name == "target" || node.name == "duck_target" {
                if let parentNode = node.parent {
                    if parentNode.zPosition > biggestZPosition {
                        biggestZPosition = parentNode.zPosition
                        shootNode = node
                    }
                }
            }
        }
        
        return shootNode
    }
    
    func addShot(imageNamed imageName:String, to node:SKSpriteNode, on positon: CGPoint) {
        let convertedPosition = self.convert(positon, to: node)
        let shot = SKSpriteNode(imageNamed: imageName)
        
        shot.position = convertedPosition
        node.addChild(shot)
        shot.run(.sequence([
            .wait(forDuration: 2),
            .fadeAlpha(to: 0, duration: 0.3),
            .removeFromParent()
            ]))
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
