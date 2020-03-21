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
    
    // MARK: Collision Categories
    let frogCategory: UInt32 = 0x1 << 0
    let carCategory: UInt32 = 0x1 << 1
    let endGameTargetCategory: UInt32 = 0x1 << 2
    
    //MARK: Frogger Health SKSpriteNode
    private var frogHealth: [SKSpriteNode] = []
    
    var heartCounter: Int = 3 {
        didSet {
            if heartCounter >= 0 {
                heartEmpty(frogHealth[heartCounter])
            }
        }
    }
    
    //MARK: Cars Nodes SKPriteNodes
    private var trackNodes: [SKSpriteNode] = []
    private var currentTrack: Int = 0
    
    
    //MARK: Cars Nodes SKPriteNodes
    private var endGameTarget: SKSpriteNode!
    
    // Constants
    let tileSize = 128
    let rows = 22
    let columns = 11
    
    let jewelryPickupPoints = 100
    
    // Scene Nodes
    var frog: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var grassTileMap: SKTileMapNode!
    var roadTileMap: SKTileMapNode!
    var sandTileMap: SKTileMapNode!
    var waterTileMap: SKTileMapNode!
    var objectsTileMap: SKTileMapNode!
    
    // Game Variables
    var score: Int!
    
    var jewelSound:SKAction = {
        return SKAction.playSoundFileNamed("jewel.wav", waitForCompletion: false)
    }()
    
    var owSound:SKAction = {
        return SKAction.playSoundFileNamed("ow.wav", waitForCompletion: false)
    }()
    
    
    override func didMove(to view: SKView) {
        setupTheDelegate()
        loadSceneNodes()
        createGestures(view)
        carsMove()
        setupObjects()
        score = 0
        updateScore(scoreDelta: 0)
    }
    
    func setupTheDelegate() {
        self.physicsWorld.contactDelegate = self
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
        scene?.scaleMode = SKSceneScaleMode.fill
        createFrog()
        createEndGameTargetNode()
        getTrackeNodes()
        setupFrogHealth()
        
        guard let scoreLabel = childNode(withName: "score") as? SKLabelNode else {
            fatalError("Score label not loaded")
        }
        
        self.scoreLabel = scoreLabel
        
        guard let grassTileMap = childNode(withName: "grassTileMap") as? SKTileMapNode else {
            fatalError("grass tile map node not loaded")
        }
        
        self.grassTileMap = grassTileMap
        
        guard let roadTileMap = childNode(withName: "roadTileMap") as? SKTileMapNode else {
            fatalError("road tile map node not loaded")
        }
        self.roadTileMap = roadTileMap
        
        guard let sandTileMap = childNode(withName: "sandTileMap") as? SKTileMapNode else {
            fatalError("sand tile map node not loaded")
        }
        
        self.sandTileMap = sandTileMap
        
        guard let waterTileMap = childNode(withName: "waterTileMap") as? SKTileMapNode else {
            fatalError("water tile map node not loaded")
        }
        self.waterTileMap = waterTileMap
        
    }
    
    func createEndGameTargetNode () {
        guard let endGameTargetNode = childNode(withName: "endGameTargetNode") as? SKSpriteNode else {
            fatalError("endGameTargetNode is not loaded")
        }
        self.endGameTarget = endGameTargetNode
        self.endGameTarget.physicsBody = SKPhysicsBody(circleOfRadius: endGameTarget.size.width / 2)
        self.endGameTarget.physicsBody?.linearDamping = 0
        self.endGameTarget.physicsBody?.categoryBitMask = endGameTargetCategory
        self.endGameTarget.physicsBody?.collisionBitMask = 0
        self.endGameTarget.physicsBody?.contactTestBitMask = frogCategory

    }
    
    func setupFrogHealth() {
        for i in 0...2 {
            if let heartNode = self.childNode(withName: "heart\(i)") as? SKSpriteNode {
                self.frogHealth.append(heartNode)
            }
        }
    }
    
    func createFrog() {
        guard let frog = childNode(withName: "frog") as? SKSpriteNode else {
            fatalError("Frog sprite not loaded")
        }
        
        self.frog = frog
        // add physic collision
        self.frog.physicsBody = SKPhysicsBody(circleOfRadius: self.frog.size.width / 2)
        self.frog.physicsBody?.linearDamping = 0
        self.frog.physicsBody?.categoryBitMask = frogCategory
        self.frog.physicsBody?.collisionBitMask = 0
        self.frog.physicsBody?.contactTestBitMask = carCategory | endGameTargetCategory
        
        // Boundary constraints
        let xRange = SKRange(lowerLimit:0 + CGFloat(tileSize), upperLimit:scene!.size.width - CGFloat(tileSize))
        let yRange = SKRange(lowerLimit:0 + CGFloat(tileSize), upperLimit:scene!.size.height - CGFloat(tileSize))
        frog.constraints = [SKConstraint.positionX(xRange,y: yRange)]
    }

    fileprivate func createCar(_ car: Car, trackPosition: CGPoint) -> SKSpriteNode {
        let carNode = SKSpriteNode(imageNamed: car.value)
        carNode.name = "CAR"
        carNode.size = CGSize(width: carNode.size.width * 2, height: carNode.size.height * 2)
        carNode.zRotation = -(.pi / 2)
        carNode.position = CGPoint(x: 0  , y: trackPosition.y)
        // add physic colission part.
        carNode.physicsBody = SKPhysicsBody(circleOfRadius: carNode.size.width / 2)
        carNode.physicsBody?.linearDamping = 0
        carNode.physicsBody?.categoryBitMask = carCategory
        carNode.physicsBody?.collisionBitMask = 0
        carNode.physicsBody?.contactTestBitMask = frogCategory
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
    
    func setupObjects() {
        let size = CGSize(width: tileSize, height: tileSize)
        
        guard let tileSet = SKTileSet(named: "Object Tiles") else {
            fatalError("Object Tiles Tile Set not found")
        }
        
        objectsTileMap = SKTileMapNode(tileSet: tileSet,
                                       columns: columns,
                                       rows: rows,
                                       tileSize: size)
        
        objectsTileMap.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(objectsTileMap)
        
        let tileGroups = tileSet.tileGroups
        
        guard let jewelTile = tileGroups.first(where: {$0.name == "Jewel"}) else {
            fatalError("No Jewel tile definition found")
        }
        
        let numberOfObjects = 10
        
        //        let maxObjectsOnGrass = numberOfObjects / 4
        //        let maxObjectsOnWater = numberOfObjects / 4
        //        let maxObjectsOnSand = numberOfObjects / 4
        //        let maxObjectsOnRoad = numberOfObjects / 4
        //
        //        var objectsOnGrass = 0
        //        var objectsOnWater = 0
        //        var objectsOnSand = 0
        //        var objectsOnRoad = 0
        
        for _ in 1...numberOfObjects {
            let column = Int.random(in: 3...columns - 3)
            let row = Int.random(in: 3...rows - 3)
            
            let grassTile = grassTileMap.tileDefinition(atColumn: column, row: row)
            let roadTile = roadTileMap.tileDefinition(atColumn: column, row: row)
            let sandTile = sandTileMap.tileDefinition(atColumn: column, row: row)
            let waterTile = waterTileMap.tileDefinition(atColumn: column, row: row)
            
            var tile : SKTileGroup?
            
            while tile == nil {
                let randNum = Int.random(in: 1...4)
                
                switch randNum {
                case 1:
                    tile = grassTile == nil ? jewelTile : nil
                    break
                case 2:
                    tile = roadTile == nil ? jewelTile : nil
                    break
                case 3:
                    tile = sandTile == nil ? jewelTile : nil
                    break
                case 4:
                    tile = waterTile == nil ? jewelTile : nil
                    break
                default:
                    print("Shouldn't be here...")
                }
            }
            
            objectsTileMap.setTileGroup(tile, forColumn: column, row: row)
        }
    }
    
    func debugPrint() {
        let position = frog.position
        let currentColumn = grassTileMap.tileColumnIndex(fromPosition: position)
        let currentRow = grassTileMap.tileRowIndex(fromPosition: position)
        
        print("Current Column: \(currentColumn) Current Row: \(currentRow)")
    }
    
    override func update(_ currentTime: TimeInterval) {
        let position = frog.position
        let currentColumn = grassTileMap.tileColumnIndex(fromPosition: position)
        let currentRow = grassTileMap.tileRowIndex(fromPosition: position)
        
        let objectTile = objectsTileMap.tileDefinition(atColumn: currentColumn, row: currentRow)
        
        if let _ = objectTile?.userData?.value(forKey: "jewel") {
            updateScore(scoreDelta: jewelryPickupPoints)
            run(jewelSound)
            objectsTileMap.setTileGroup(nil, forColumn: currentColumn, row: currentRow)
        }

    }
    
    func removeAllTheNodesOutsideTheScene(_ trackNode: SKSpriteNode) {
        self.enumerateChildNodes(withName: "CAR") { (node:SKNode, nil) in
            if node.position.x < 0 || node.position.x > trackNode.size.width {
                node.removeFromParent()
            }
        }
    }
    
    func updateScore(scoreDelta: Int){
        score += scoreDelta
        scoreLabel.text = String(score)
    }
}


extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var frogBody:SKPhysicsBody
        var hittedBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            frogBody = contact.bodyA
            hittedBody = contact.bodyB
        }else{
            frogBody = contact.bodyB
            hittedBody = contact.bodyA
        }
        
        if frogBody.categoryBitMask == frogCategory && hittedBody.categoryBitMask == carCategory {
            frogHitCarAnimationFeedback()
            
        } else if frogBody.categoryBitMask == frogCategory && hittedBody.categoryBitMask == endGameTargetCategory {
            print("hello world")
            presentEndGameScene(score: self.score, message: "Congratulations!")
        }
    }
    
    func frogHitCarAnimationFeedback() {
        run(owSound)
        heartCounter = heartCounter - 1
        if heartCounter == 0 {
            presentEndGameScene(score: self.score, message: "Sorry, try again!")
            return
        }
        let frogHideAction = SKAction.run {
            self.frog.alpha = 0.0
        }
        let frogUnHideAction = SKAction.run {
            self.frog.alpha = 1.0
        }
        
        let waitAction = SKAction.wait(forDuration: 4.0)
        
        let finalAction = SKAction.repeat(SKAction.sequence([frogHideAction, frogUnHideAction, waitAction]), count: 10)
        self.run(finalAction)
    }
    
    func presentEndGameScene(score: Int, message: String) {
        let transition = SKTransition.fade(withDuration: 1)
        let endGameScene: EndGameScene = SKScene(fileNamed: "EndGameScene") as! EndGameScene
        endGameScene.scaleMode = .aspectFit
        endGameScene.score = score
        endGameScene.messageTitle = message
        self.view?.presentScene(endGameScene, transition: transition)

    }
}

//MARK: helper Method
extension GameScene {
    
    func heartFilled(_ ndoe: SKSpriteNode) {
        ndoe.texture = SKTexture(imageNamed: "heart-fill")
    }
    
    func heartEmpty(_ ndoe: SKSpriteNode) {
        ndoe.texture = SKTexture(imageNamed: "heart-empty")
    }
}
