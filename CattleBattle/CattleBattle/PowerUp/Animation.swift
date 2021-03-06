//
//  Animation.swift
//  CattleBattle
//
//  Created by jarvis on 4/15/15.
//  Copyright (c) 2015 Cattle Battle. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Animation {
    
    struct Constants {
        internal static let POWERUP_KEYWORD = "item"
        internal static let DRAGGING_KEYWORD = "dragging-"
        internal static let IMAGE_EXT = ".png"
        internal static let IMAGE_SCALE: CGFloat = 0.3
        
        internal static let Z_INDEX_FRONT: CGFloat = 1000000
    }
    
    private class func _applyBlackHole(scene: SKScene, node: AnimalNode) {
        var blackHole = AnimationNode(imageName: "animation-blackHole", scale: 0.1, parentScale: node.animal.getImageScale())
        blackHole.rotateForever(CGFloat(-M_PI), speed: 0.2)
        blackHole.zPosition = -1
        
        node.anchorPoint = CGPointMake(0.5, 0.5)
        node.position.y += node.size.height/2
        
        blackHole.position = CGPoint.zeroPoint
        node.addChild(blackHole)
        
        blackHole.runAction(SKAction.scaleTo(1, duration: 0.6), completion: { () -> Void in
            node.runAction(SKAction.scaleTo(0, duration: 0.3), completion: { () -> Void in
                node.removeFromParent()
            })
        })
        GameSound.Constants.instance.play(.BLACKHOLE)
    }
    
    private class func _applyFreezing(scene: SKScene, nodes: [AnimalNode]) {
        let fallingIce = SKEmitterNode.getEmitterFromFile("freeze")
        let fog = SKEmitterNode.getEmitterFromFile("ice-fog")
        
        fallingIce.position = CGPointMake(scene.frame.width/2, scene.frame.height)
        fallingIce.particleLifetime = (scene.frame.height - nodes[0].position.y) / fallingIce.particleSpeed
        fallingIce.zPosition = Constants.Z_INDEX_FRONT
        
        fog.position = CGPointMake(scene.frame.width/2, nodes[0].position.y)
        fog.zPosition = Constants.Z_INDEX_FRONT + 1
        
        scene.addChild(fallingIce)
        scene.addChild(fog)
        
        for node in nodes {
            var freezing = AnimationNode(imageName: "animation-freezing2.png", scale: 0.4, parentScale: node.animal.getImageScale())
            freezing.alpha = 0
            freezing.anchorPoint = CGPointMake(0.5, 0.2)
            freezing.position = CGPoint.zeroPoint
            freezing.zPosition = 1
            
            node.addChild(freezing)
            
            var action1 = SKAction.runBlock({
                node.physicsBody!.dynamic = false
                freezing.runAction(SKAction.fadeInWithDuration(0.5), completion: {
                    node.paused = true
                })
            })
            var action2 = SKAction.waitForDuration(5)
            var action3 = SKAction.runBlock({
                node.paused = false
                freezing.runAction(SKAction.fadeOutWithDuration(0.5), completion: {
                    node.physicsBody!.dynamic = true
                    freezing.removeFromParent()
                })
            })
            
            scene.runAction(SKAction.sequence([action1, action2, action3]))
        }
        GameSound.Constants.instance.play(.FREEZE)
    }
    
    private class func _applyUpgrading(scene: SKScene, node: AnimalNode) {
        var upgradeSmoke = SKEmitterNode.getEmitterFromFile("upgrade")
        upgradeSmoke.zPosition = 1
        
        upgradeSmoke.particlePositionRange = CGVectorMake(node.size.width*2, node.size.height*2)
        upgradeSmoke.position = CGPointMake(0, node.size.height)
        node.addChild(upgradeSmoke)
        
        var nextSize = find(Animal.Size.allSizes, node.animal.size)! + 1
        if nextSize < Animal.Size.allSizes.count {
            node.updateAnimalType(Animal.Size.allSizes[nextSize])
        }
        GameSound.Constants.instance.play(.UPGRADE)
    }
    
    private class func _applyFiring(scene: SKScene, node: AnimalNode) {
        let fire = SKEmitterNode.getEmitterFromFile("fire")
        fire.zPosition = -1
        fire.position = node.position
        fire.position.y += node.size.height * 5 / 9
        
        node.physicsBody = nil
        
        node.zPosition = Constants.Z_INDEX_FRONT
        node.xScale = -1
        
        var destination = node.animal.side == .LEFT ? GameScene.Constants.GAME_VIEW_LEFT_BOUNDARY : GameScene.Constants.GAME_VIEW_RIGHT_BOUNDARY
        
        var action = SKAction.moveToX(destination, duration: Double(abs(destination - node.position.x)) / Double(AnimalNode.Constants.VELOCITY*1.5))
        
        fire.targetNode = scene
        fire.runAction(action)
        node.runAction(action)
        
        scene.addChild(fire)
    }
    
    internal class func applyPowerUp(powerUpItem: PowerUpNode?, targets: [AnimalNode], scene: GameScene, removeItemFunc: ((PowerUpNode) -> ())) {
        var animal = targets[0]
        if var item = powerUpItem {
            if item.powerUpItem.powerType == .BLACK_HOLE {
                Animation._applyBlackHole(scene, node: animal)
                
            } else if item.powerUpItem.powerType == .FREEZE {
                Animation._applyFreezing(scene, nodes: targets)
                
            } else if item.powerUpItem.powerType == .FIRE {
                Animation._applyFiring(scene, node: animal)
                
            } else if item.powerUpItem.powerType == .UPGRADE {
                Animation._applyUpgrading(scene, node: animal)
            }
            removeItemFunc(item)
        }
    }
    
    internal class func draggingPowerUp(powerType: PowerUp.PowerType, scene: SKScene, position: CGPoint) -> SKEmitterNode {
        var fileName = Constants.DRAGGING_KEYWORD + powerType.rawValue
        var effect = SKEmitterNode.getEmitterFromFile(fileName)
        effect.zPosition = -1
        effect.position = position
        effect.targetNode = scene
        scene.addChild(effect)
        return effect
    }
}
