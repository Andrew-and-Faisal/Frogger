//
//  GameScene.swift
//  Frogger
//
//  Created by Andrew Lvovsky on 3/14/20.
//  Copyright © 2020 Andrew Lvovsky and Faisal AlMaarik. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Constants
    let tileSize = 128
    
    // Scene Nodes
    var frog: SKSpriteNode!
    var grassBackground: SKTileMapNode!
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeRight(sender:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeLeft(sender:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeUp(sender:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeDown(sender:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        frog.zRotation = (3 * .pi) / 2
        frog.position = CGPoint(x: frog.position.x + CGFloat(tileSize), y: frog.position.y)
    }
    
    @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
        frog.zRotation = .pi / 2
        frog.position = CGPoint(x: frog.position.x - CGFloat(tileSize), y: frog.position.y)
    }
    
    @objc func swipeUp(sender: UISwipeGestureRecognizer) {
        frog.zRotation = 0
        frog.position = CGPoint(x: frog.position.x, y: frog.position.y + CGFloat(tileSize))
    }
    
    @objc func swipeDown(sender: UISwipeGestureRecognizer) {
        frog.zRotation = .pi
        frog.position = CGPoint(x: frog.position.x, y: frog.position.y - CGFloat(tileSize))
    }
    
    func loadSceneNodes() {
        guard let frog = childNode(withName: "frog") as? SKSpriteNode else {
            fatalError("Frog sprite not loaded")
        }
        self.frog = frog
        
        guard let grassBackground = childNode(withName: "grassBackground") as? SKTileMapNode else {
            fatalError("Background tile map node not loaded")
        }
        self.grassBackground = grassBackground
        
        // Boundary constraints
        let xRange = SKRange(lowerLimit:0 + CGFloat(tileSize), upperLimit:scene!.size.width - CGFloat(tileSize))
        let yRange = SKRange(lowerLimit:0 + CGFloat(tileSize), upperLimit:scene!.size.height - CGFloat(tileSize))
        frog.constraints = [SKConstraint.positionX(xRange,y: yRange)]
    }
    
    override func update(_ currentTime: TimeInterval) {
        // empty
    }
}
