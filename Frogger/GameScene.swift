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
  
  // constants
  let waterMaxSpeed: CGFloat = 200
  let landMaxSpeed: CGFloat = 4000

  // if within threshold range of the target, frog begins slowing
  let targetThreshold:CGFloat = 200

  var maxSpeed: CGFloat = 0
  var acceleration: CGFloat = 0
  
  // touch location
  var targetLocation: CGPoint = .zero
  
  // Scene Nodes
  var frog:SKSpriteNode!

  override func didMove(to view: SKView) {
    loadSceneNodes()
    physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    maxSpeed = landMaxSpeed
  }
  
  func loadSceneNodes() {
    guard let frog = childNode(withName: "frog") as? SKSpriteNode else {
      fatalError("Sprite Nodes not loaded")
    }
    self.frog = frog
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    targetLocation = touch.location(in: self)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    targetLocation = touch.location(in: self)
  }
  
  
  override func update(_ currentTime: TimeInterval) {
  }
  
  override func didSimulatePhysics() {
    
    let offset = CGPoint(x: targetLocation.x - frog.position.x,
                         y: targetLocation.y - frog.position.y)
    let distance = sqrt(offset.x * offset.x + offset.y * offset.y)
    let frogDirection = CGPoint(x:offset.x / distance,
                               y:offset.y / distance)
    let frogVelocity = CGPoint(x: frogDirection.x * acceleration,
                              y: frogDirection.y * acceleration)
    
    frog.physicsBody?.velocity = CGVector(dx: frogVelocity.x, dy: frogVelocity.y)
    
    if acceleration > 5 {
      frog.zRotation = atan2(frogVelocity.y, frogVelocity.x)
    }
    
    // update acceleration
    // frog speeds up to maximum
    // if within threshold range of the target, frog begins slowing
    // if maxSpeed has reduced due to different tiles,
    // may need to decelerate slowly to the new maxSpeed
    
    if distance < targetThreshold {
      let delta = targetThreshold - distance
      acceleration = acceleration * ((targetThreshold - delta)/targetThreshold)
      if acceleration < 2 {
        acceleration = 0
      }
    } else {
      if acceleration > maxSpeed {
        acceleration -= min(acceleration - maxSpeed, 80)
      }
      if acceleration < maxSpeed {
        acceleration += min(maxSpeed - acceleration, 40)
      }
    }

  }
}
