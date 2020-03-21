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
    let rows = 22
    let columns = 11
    
    // Scene Nodes
    var frog: SKSpriteNode!
    var grassTileMap: SKTileMapNode!
    var roadTileMap: SKTileMapNode!
    var sandTileMap: SKTileMapNode!
    var waterTileMap: SKTileMapNode!
    var objectsTileMap: SKTileMapNode!
    
    var jewelSound:SKAction = {
        return SKAction.playSoundFileNamed("jewel.wav", waitForCompletion: false)
    }()
    
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
        
        setupObjects()
    }
    
    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        frog.zRotation = (3 * .pi) / 2
        frog.position = CGPoint(x: frog.position.x + CGFloat(tileSize), y: frog.position.y)
//        debugPrint()
    }
    
    @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
        frog.zRotation = .pi / 2
        frog.position = CGPoint(x: frog.position.x - CGFloat(tileSize), y: frog.position.y)
//        debugPrint()
    }
    
    @objc func swipeUp(sender: UISwipeGestureRecognizer) {
        frog.zRotation = 0
        frog.position = CGPoint(x: frog.position.x, y: frog.position.y + CGFloat(tileSize))
//         debugPrint()
    }
    
    @objc func swipeDown(sender: UISwipeGestureRecognizer) {
        frog.zRotation = .pi
        frog.position = CGPoint(x: frog.position.x, y: frog.position.y - CGFloat(tileSize))
//        sdebugPrint()
    }
    
    func loadSceneNodes() {
        scene?.scaleMode = SKSceneScaleMode.fill
        
        guard let frog = childNode(withName: "frog") as? SKSpriteNode else {
            fatalError("Frog sprite not loaded")
        }
        self.frog = frog
        
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
        
        // Boundary constraints
        let xRange = SKRange(lowerLimit:0 + CGFloat(tileSize), upperLimit:scene!.size.width - CGFloat(tileSize))
        let yRange = SKRange(lowerLimit:0 + CGFloat(tileSize), upperLimit:scene!.size.height - CGFloat(tileSize))
        frog.constraints = [SKConstraint.positionX(xRange,y: yRange)]
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
            run(jewelSound)
            objectsTileMap.setTileGroup(nil, forColumn: currentColumn, row: currentRow)
        }
        
        
    }
}
