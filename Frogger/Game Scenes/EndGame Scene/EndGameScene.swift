//
//  EndGameScene.swift
//  Frogger
//
//  Created by Faisal AlMaarik on 3/20/20.
//  Copyright © 2020 Andrew Lvovsky and Faisal AlMaarik. All rights reserved.
//

import SpriteKit
import GameplayKit

class EndGameScene: GameScene {
    
    //MARK: EndGameScene nodes
    var startNewGameButtonNode: SKSpriteNode!
    var scoreLabelNode: SKLabelNode!
    var messgeTitleLabelNode: SKLabelNode!
    var startGameScene : SKScene!
    
    var messageTitle: String = "" {
        didSet {
            guard let messagelabelNode = self.childNode(withName: "messgeTitleLabelNode") as? SKLabelNode else { fatalError()  }
            self.messgeTitleLabelNode = messagelabelNode
            messgeTitleLabelNode.text = messageTitle
        }
    }
    
    var gameScore: Int = 0 {
        didSet {
            guard let scoreLabelButton = self.childNode(withName: "scoreLabelNode") as? SKLabelNode else { fatalError()  }
            self.scoreLabelNode = scoreLabelButton
            scoreLabelNode.text = "\(gameScore)"
        }
    }
    
    override func didMove(to view: SKView) {
        loadTheScene()
    }
    
    func loadTheScene() {
        guard let startButtonNode = self.childNode(withName: "startNewGameButtonNode") as? SKSpriteNode else { fatalError()  }
        self.startNewGameButtonNode = startButtonNode
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            if node == startNewGameButtonNode {
                let transition = SKTransition.fade(withDuration: 1)
                startGameScene = SKScene(fileNamed: "StartGameScene")
                startGameScene.scaleMode = .aspectFit
                self.view?.presentScene(startGameScene, transition: transition)
            }
        }
    }
}
