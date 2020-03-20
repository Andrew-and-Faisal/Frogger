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
        
        debugPrint()
    }
    
    @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
        frog.zRotation = .pi / 2
        frog.position = CGPoint(x: frog.position.x - CGFloat(tileSize), y: frog.position.y)
        
        debugPrint()
    }
    
    @objc func swipeUp(sender: UISwipeGestureRecognizer) {
        frog.zRotation = 0
        frog.position = CGPoint(x: frog.position.x, y: frog.position.y + CGFloat(tileSize))
        
        debugPrint()
    }
    
    @objc func swipeDown(sender: UISwipeGestureRecognizer) {
        frog.zRotation = .pi
        frog.position = CGPoint(x: frog.position.x, y: frog.position.y - CGFloat(tileSize))
        
        debugPrint()
    }
    
    func loadSceneNodes() {
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
        
        // 1
        guard let tileSet = SKTileSet(named: "Object Tiles") else {
            fatalError("Object Tiles Tile Set not found")
        }
        
        // 2
        objectsTileMap = SKTileMapNode(tileSet: tileSet,
                                       columns: columns,
                                       rows: rows,
                                       tileSize: size)
        
        // 3
        addChild(objectsTileMap)
        
        // 4
        let tileGroups = tileSet.tileGroups
        
        // 5
        guard let duckTile = tileGroups.first(where: {$0.name == "Duck"}) else {
            fatalError("No Duck tile definition found")
        }
        //        guard let gascanTile = tileGroups.first(where: {$0.name == "Gas Can"}) else {
        //            fatalError("No Gas Can tile definition found")
        //        }
        
        // 6
        let numberOfObjects = 10
        
        // 7
        for _ in 1...numberOfObjects {
            // 8
            let column = Int(arc4random_uniform(UInt32(columns)))
            let row = Int(arc4random_uniform(UInt32(rows)))
            
            let grassTile = grassTileMap.tileDefinition(atColumn: column, row: row)
            let roadTile = roadTileMap.tileDefinition(atColumn: column, row: row)
            let sandTile = sandTileMap.tileDefinition(atColumn: column, row: row)
            let waterTile = waterTileMap.tileDefinition(atColumn: column, row: row)
            
            // 9
            var tile : SKTileGroup?
            
            while tile == nil {
                let randNum = Int.random(in: 1...4)
                
                switch randNum {
                case 1:
                    tile = grassTile == nil ? duckTile : nil
                    break
                case 2:
                    tile = roadTile == nil ? duckTile : nil
                    break
                case 3:
                    tile = sandTile == nil ? duckTile : nil
                    break
                case 4:
                    tile = waterTile == nil ? duckTile : nil
                    break
                default:
                    print("Shouldn't be here...")
                }
            }
            
            print("Column: \(column) Row: \(row)")
            
            if tile != nil {
                print("duck")
            }
            else {
                print("not duck")
            }
            
            // 10
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

            
        if let _ = objectTile?.userData?.value(forKey: "duck") {
          objectsTileMap.setTileGroup(nil, forColumn: currentColumn, row: currentRow)
        }
    }
}
