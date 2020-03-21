//
//  StartGameScene.swift
//  Frogger
//
//  Created by Faisal AlMaarik on 3/20/20.
//  Copyright © 2020 Andrew Lvovsky and Faisal AlMaarik. All rights reserved.
//

import SpriteKit
import GameplayKit



class StartGameScene: GameScene {
    
    //MARK: StartGameScene nodes
    var playButtonNode: SKSpriteNode!
    var playLabelNode: SKLabelNode!
    var gameScene:SKScene!
    
    override func didMove(to view: SKView) {
        guard let buttonNode = self.childNode(withName: "playButton") as? SKSpriteNode else { fatalError()  }
        guard let labelNode = self.childNode(withName: "playLabel") as? SKLabelNode else { fatalError()  }
        self.playButtonNode = buttonNode
        self.playLabelNode = labelNode
        
    }
    override func update(_ currentTime: TimeInterval) {
        
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


