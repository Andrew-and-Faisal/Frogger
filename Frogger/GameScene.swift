//
//  GameScene.swift
//  Frogger
//
//  Created by Andrew Lvovsky on 3/14/20.
//  Copyright © 2020 Andrew Lvovsky and Faisal AlMaarik. All rights reserved.
//

import SpriteKit
import GameplayKit


enum Car: Int {
    case yellow, red, black, blue
    var value: String {
        switch self {
        case .yellow:
            return "car_yellow_4"
        case .red:
            return "car_red_3"
        case .black:
            return "car_black_1"
        case .blue:
            return "car_blue_2"
        }
    }
}

class GameScene: SKScene {
    
    //MARK: Frogger Health SKSpriteNode
    private var heartZero: SKSpriteNode!
    private var heartOne: SKSpriteNode!
    private var heartTwo: SKSpriteNode!
    
    
    var heartCounter: Int = 3 {
        didSet {
            if heartCounter >= 0 && heartCounter <= 3 {
                switch heartCounter {
                case 0:
                    self.heartEmpty(heartZero)
                case 1:
                    self.heartEmpty(heartOne)
                case 2:
                    self.heartEmpty(heartOne)
                default:
                    return
                }
            }
        }
    }
    
    //MARK: Cars Nodes SKPriteNodes
    private var trackNodes: [SKSpriteNode] = []
    private var currentTrack: Int = 0
    
    // Constants
    let tileSize = 128
    
    // Scene Nodes
    var frog: SKSpriteNode!
    var grassBackground: SKTileMapNode!
    
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
        createGestures(view)
        carsMove()
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
    
    fileprivate func getTrackeNodes() {
        for i in 0...1 {
            if let trackNode = self.childNode(withName: "track\(i)") as? SKSpriteNode {
                self.trackNodes.append(trackNode)
            }
        }
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
        
        getTrackeNodes()
    }
    
    fileprivate func createCar(_ car: Car, trackPosition: CGPoint) -> SKSpriteNode {
        let carNode = SKSpriteNode(imageNamed: car.value)
        carNode.name = "CAR"
        carNode.size = CGSize(width: carNode.size.width * 2, height: carNode.size.height * 2)
        carNode.zRotation = -(.pi / 2)
        carNode.position = CGPoint(x: 0  , y: trackPosition.y)
        self.addChild(carNode)
        return carNode
    }
    
    fileprivate func createGestures(_ view: SKView) {
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
    
    fileprivate func carsMove() {
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            let randomCarIntValue = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
            let randomTrackValue = GKRandomSource.sharedRandom().nextInt(upperBound: 2)
            let randomTrack = self.trackNodes[randomTrackValue]
            guard let randomCar = Car(rawValue: randomCarIntValue) else { return }
            let carNode = self.createCar(randomCar, trackPosition: randomTrack.position)
            let moveAction = SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 0.02)
            let repeatAction = SKAction.repeatForever(moveAction)
            carNode.run(repeatAction)
            self.removeAllTheNodesOutsideTheScene(randomTrack)
            }, SKAction.wait(forDuration: 2.0)])))
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    func removeAllTheNodesOutsideTheScene(_ trackNode: SKSpriteNode) {
        self.enumerateChildNodes(withName: "CAR") { (node:SKNode, nil) in
            if node.position.x < 0 || node.position.x > trackNode.size.width {
                node.removeFromParent()
            }
        }
    }
}


//MARK: helper Method

extension GameScene {
    
    func heartFilled(_ ndoe: SKSpriteNode) {
        heartOne.texture = SKTexture(imageNamed: "heart-fill")
    }
    
    func heartEmpty(_ ndoe: SKSpriteNode) {
        heartOne.texture = SKTexture(imageNamed: "heart-empty")
    }
}
