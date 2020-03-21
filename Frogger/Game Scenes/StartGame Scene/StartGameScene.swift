//
//  StartGameScene.swift
//  Frogger
//
//  Created by Faisal AlMaarik on 3/20/20.
//  Copyright © 2020 Andrew Lvovsky and Faisal AlMaarik. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


class StartGameScene: GameScene {
    
    //MARK: StartGameScene nodes
    var playButtonNode: SKSpriteNode!
    var playLabelNode: SKLabelNode!
    var gameScene:SKScene!
    
    var startFrog : SKSpriteNode!
    var motionManager = CMMotionManager()
    var destX : CGFloat = 0.0
    var destY : CGFloat = 0.0
    
    override func createFrog() {
        guard let startSceneFrog = self.childNode(withName: "startSceneFrog") as? SKSpriteNode else {
            fatalError("startFrog sprite not loaded")
        }
        
        self.startFrog = startSceneFrog
        startFrog.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        // Boundary constraints
        let xRange = SKRange(lowerLimit:0 + CGFloat(tileSize), upperLimit:scene!.size.width - CGFloat(tileSize))
        let yRange = SKRange(lowerLimit:0 + CGFloat(tileSize), upperLimit:scene!.size.height - CGFloat(tileSize))
        startFrog.constraints = [SKConstraint.positionX(xRange,y: yRange)]
    }
    
    override func didMove(to view: SKView) {
        guard let buttonNode = self.childNode(withName: "playButton") as? SKSpriteNode else { fatalError()  }
        guard let labelNode = self.childNode(withName: "playLabel") as? SKLabelNode else { fatalError()  }
        self.playButtonNode = buttonNode
        self.playLabelNode = labelNode
        
        createFrog()
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01
            motionManager.startAccelerometerUpdates(to: .main) {
                (data, error) in
                guard let data = data, error == nil else {
                    return
                }
                
                let currentX = self.startFrog.position.x
                let currentY = self.startFrog.position.y
                self.destX = currentX + CGFloat(data.acceleration.x * 5000)
                self.destY = currentY + CGFloat(data.acceleration.y * 5000)
            }
        }
        
    }
    override func update(_ currentTime: TimeInterval) {
        let xAction = SKAction.moveTo(x: destX, duration: 1)
        let yAction = SKAction.moveTo(y: destY, duration: 1)
        startFrog.run(xAction)
        startFrog.run(yAction)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playButtonNode || node == playLabelNode {
                let transition = SKTransition.fade(withDuration: 1)
                gameScene = SKScene(fileNamed: "GameScene")
                gameScene.scaleMode = .aspectFit
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
}


