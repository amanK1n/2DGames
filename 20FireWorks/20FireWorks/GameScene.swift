//
//  GameScene.swift
//  20FireWorks
//
//  Created by Sayed on 15/08/25.
//

import SpriteKit

class GameScene: SKScene {
//    var scoreLabel: SKLabelNode?
    var gameTimer: Timer?
    var fireWorks = [SKNode]()
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            
          // scoreLabel?.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
    
//        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
//           scoreLabel?.fontColor = .white
//           scoreLabel?.fontSize = 20
//           scoreLabel?.text = "Score: \(score)"
//           scoreLabel?.position = CGPoint(x: 800, y: 700)
//
//           if let scoreLabel = scoreLabel {
//               addChild(scoreLabel)
//           }
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    func createFirework(xMovement: CGFloat, x: Int, y: Int, color: UIColor? = nil) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .red
        case 1:
            firework.color = .cyan
        case 2:
            firework.color = .green
        default:
            break
        }
//        firework.color = color ?? .black
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 120)
        node.run(move)
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 5, y: -24)
            node.addChild(emitter)
        }
        
        fireWorks.append(node)
        addChild(node)
    }
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 2800
        
        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge, color: .white)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge, color: .orange)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge, color: .orange)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge, color: .green)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge, color: .green)
            
        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge, color: .white)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge, color: .orange)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge, color: .orange)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge, color: .green)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge, color: .green)
            
        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400, color: .orange)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300, color: .orange)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200, color: .white)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100, color: .green)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge, color: .green)
            
        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400, color: .orange)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300, color: .orange)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200, color: .white)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100, color: .green)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge, color: .green)
            
        default:
            break
        }
    }
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            for parent in fireWorks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireWorks.enumerated().reversed() {
            if firework.position.y > 900 {
                // this uses a position high above so that rockets can explode off screen
                fireWorks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
        }

        firework.removeFromParent()
    }
    func explodeFireworks() {
        var numExploded = 0

        for (index, fireworkContainer) in fireWorks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }

            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireWorks.remove(at: index)
                numExploded += 1
            }
        }

        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
}
