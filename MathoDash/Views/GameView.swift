//
//  GameView.swift
//  MathoDash
//
//  Created by Kelly Florences Tanjaya on 02/08/23.
//

import SwiftUI
import SpriteKit
import CoreMotion
import GameKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case spike = 4
    case finish = 8
    case finish_correct = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let manager : CMMotionManager = CMMotionManager()
    let loader = LoadMaze()
    let solve = MathSolver()
    
    //    get accelerometer data
    private var accelerometerData: CMAcceleration?
    private var maxAccelerationMagnitude: Double = 0.0
    private var minAccelerationMagnitude: Double = Double.infinity
    private var lastAccelerationMagnitude: Double = 0.0
    private var xAcceleration: CGFloat = 0.0
    
    //    Check animation state
    private var isAnimationRunning: Bool = false // Flag to track animation state
    var isOnGround = true
    private var isJumpEnabled: Bool = true // Flag to track jump availability
    
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    //    Sprite setup variable
    var textureArray = [SKTexture]()
    var slime = SKSpriteNode()
    var playerName = SKLabelNode()
    
    // timer countdown
    private var countdownLabel: SKLabelNode!
    private var counter: Int = 7
    private var countdownTimer: Timer?
    
    //alert text for wrong answers
    private var alertLabel: SKLabelNode!
    private var questionLabel: SKLabelNode!
    
    var dimmed = SKSpriteNode()
        
    override func didMove(to view: SKView) {
//        loader.drawBoard()
        loader.loadMazeRound()
        self.addChild(loader.mazeObstacles)
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.scaleMode = .aspectFill
        self.addChild(loader.pinggiranMap)
        
        loader.loadAnswers()
        
        //countdown
        startCountdown()
        dimBG()
        
    }
   
    //   Setting up collision between object
    func didBegin(_ contact: SKPhysicsContact){
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        
        if nodeA == slime {
            playerCollided(with: nodeB)
        } else if nodeB == slime {
            playerCollided(with: nodeA)
        }
    }
    
    func createSpike(){
        //        Obstacle
        let node = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 10))
        node.name = "spike"
        node.position = CGPoint(x: size.width/2, y: size.height/2)
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 10))
        
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.spike.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        addChild(node)
    }
    
    func createPlayer(){
        slime.removeFromParent()
        //        Adding slime texture
        for i in 1...5{
            let textureName = "slime_move_\(i)"
            textureArray.append(SKTexture(imageNamed: textureName))
        }
        
        //        adding slime sprite
        if textureArray.count > 1{
            let imageFrame = textureArray.first
            let size = CGFloat(loader.squareMinSize)

            slime = SKSpriteNode(texture: imageFrame)
//            slime.position = CGPoint(x: size.width/2, y: size.height/3)
            slime.position = CGPoint(x: Double(UIScreen.main.bounds.width/2), y: Double(loader.squareMinSize*1.5))
            slime.size = CGSize(width: size, height: size)
//            slime.physicsBody = SKPhysicsBody(texture: slime.texture!,size: slime.texture!.size())
            slime.physicsBody = SKPhysicsBody(texture: slime.texture!,size: CGSize(width: size, height: size))
            slime.physicsBody?.allowsRotation = false
            slime.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
            slime.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
            slime.physicsBody?.contactTestBitMask = CollisionTypes.spike.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.finish_correct.rawValue
            slime.zPosition = 1.0
            addChild(slime)
        }
        
        slime.run(SKAction.repeatForever(SKAction.animate(with: textureArray, timePerFrame: 0.1)))
        
        //add player name along with the slime
        playerName.removeFromParent()
        playerName.text = "kgraphy"
        playerName.fontName = "AvenirNext-HeavyItalic"
        playerName.color = .white
        playerName.fontSize = 10
        playerName.position = slime.position
        playerName.zPosition = slime.zPosition
        addChild(playerName)
    }
    
    func playerCollided(with node: SKNode){
        if node.name == "spike"{
            
            slime.physicsBody?.isDynamic = false
//            let remove = SKAction.removeFromParent()
            slime.removeFromParent()
            playerName.removeFromParent()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                self.createPlayer()
            }
        }else if node.name == "finish"{
            print("SALAH WKWK")
            doneFinish(wrong: true)
        }else if node.name == "finish_correct"{
            print("BENAR WKWK")
            doneFinish(wrong: false)
        }
        print("node nameme", node.name)
    }
    // This method is called in the GameViewController to set the xAcceleration value
    func updateXAcceleration(_ acceleration: CGFloat) {
        xAcceleration = acceleration
    }
    
    func doneFinish(wrong: Bool){
        alertLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        alertLabel.fontSize = 80
        alertLabel.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        alertLabel.zPosition = dimmed.zPosition + 1
        alertLabel.verticalAlignmentMode = .center
        alertLabel.fontColor = UIColor(Color("lightYellow"))
        self.addChild(alertLabel)
        dimBG()
        
        slime.physicsBody?.isDynamic = false
        let remove = SKAction.removeFromParent()
        slime.run(remove)
        playerName.run(remove)
        
        if(wrong){
            alertLabel.text = "Wrong Answer"
        }else{
            alertLabel.text = "You Win!"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            if(wrong){
                rmDimBG()
                createPlayer()
                alertLabel.removeFromParent()
            }else{
                //kalo player menang..
                nextRound()
            }
        }
    }
    
    func nextRound(){
        if(loader.round < 3){
            loader.round += 1
            
            //remove all parents
            loader.mazeObstacles.removeFromParent()
            loader.pinggiranMap.removeFromParent()
            loader.answers.removeFromParent()
            self.removeAllChildren()
            
            //        loader.drawBoard()
            loader.loadMazeRound()
            self.addChild(loader.mazeObstacles)
            self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.scaleMode = .aspectFill
            self.addChild(loader.pinggiranMap)
            
            loader.loadAnswers()
            
            //countdown
            startCountdown()
            dimBG()
        }else{
            
        }
    }
    
//    func startCountdown() {
//        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let self = self else {
//                timer.invalidate()
//                return
//            }
//
//            if self.counter > 0 {
//                self.countdownLabel.text = "\(self.counter)"
//                self.counter -= 1
//            } else if self.counter == 0{
//                self.countdownLabel.text = "Go!"
//                self.counter -= 1
//            }else{
//                // Call a function to handle the end of the countdown
//                timer.invalidate()
//                self.countdownLabel.text = ""
//                self.countdownFinished()
//            }
//        }
//    }
    
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.counter > 4 {
                self.countdownLabel.text = "\(self.counter - 4)"
                self.counter -= 1
            } else if self.counter == 4{
                self.countdownLabel.text = "Go!"
                self.counter -= 1
            } else if self.counter > 0{
                self.countdownLabel.text = loader.question
                self.counter -= 1
            }
            else {
                timer.invalidate()
                self.countdownLabel.text = ""
                self.countdownFinished()
                self.rmDimBG()
            }
        }
        
        countdownLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        countdownLabel.fontSize = 100
        countdownLabel.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.zPosition = 3
        countdownLabel.fontColor = UIColor(Color("lightYellow"))
        addChild(countdownLabel)
        
        //what happens after timer ends
        let time = Double(counter) + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [self] in
            loadGravity()
            self.createPlayer()
            self.countdownLabel.removeFromParent()
            self.addChild(loader.answers)
        }
    }
    

    func countdownFinished() {
        // Implement your logic here when the countdown finishes
        // For example, start a game, show a message, etc.
    }
    
    func dimBG(){
        dimmed = SKSpriteNode(color: UIColor.black, size: self.size)
        dimmed.alpha = 0.75
        dimmed.zPosition = countdownLabel.zPosition - 1
        dimmed.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        addChild(dimmed)
    }

    func rmDimBG(){
        dimmed.removeFromParent()
    }
    
    func loadGravity(){
        //        Start Accelerometer updates
        manager.deviceMotionUpdateInterval = 1
        manager.startDeviceMotionUpdates()
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.main){
            (data, error) in
            
            
//            self.physicsWorld.gravity = CGVectorMake(CGFloat((data?.acceleration.x)!) * 10, CGFloat((data?.acceleration.y)!) * 10)
            self.physicsWorld.gravity = CGVectorMake(CGFloat((data?.acceleration.y)!) * -10, CGFloat((data?.acceleration.x)!) * 10)


            self.physicsWorld.contactDelegate = self
            self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
            
            if let acceleration = data?.acceleration {
                self.accelerometerData = acceleration
//                let accelerationMagnitude = sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z)
                let accelerationMagnitude = sqrt(acceleration.y * acceleration.y + acceleration.x * acceleration.x + acceleration.z * acceleration.z)
                self.maxAccelerationMagnitude = max(self.maxAccelerationMagnitude, accelerationMagnitude)
                self.minAccelerationMagnitude = min(self.minAccelerationMagnitude, accelerationMagnitude)
                
            }
            
            // Start accelerometer updates and call update method of GameScene
            if let accelerometerData = data {
//                let accelerationX = CGFloat(accelerometerData.acceleration.x) * 0.75
                let accelerationX = CGFloat(-accelerometerData.acceleration.x) * 0.75
                self.updateXAcceleration(accelerationX)
                
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        playerName.position = CGPoint(x: slime.position.x, y: slime.position.y - CGFloat(loader.squareMinSize / 1.5))

        // Check if there is accelerometer data available
        if let accelerometerData = accelerometerData {
            
//            print("there is data")
            // Calculate the acceleration magnitude (you can adjust the sensitivity as needed)
            let accelerationMagnitude = sqrt(accelerometerData.x * accelerometerData.x + accelerometerData.y * accelerometerData.y + accelerometerData.z * accelerometerData.z)
            
//            print("magnitude: ", accelerationMagnitude)
            
            // Adjust the animation speed based on the acceleration magnitude
            //most fast
            let maxTimePerFrame: TimeInterval = 0.1 // Set the maximum time per frame (adjust as needed)
            //most slow
            let minTimePerFrame: TimeInterval = 1.0 // Set the minimum time per frame (adjust as needed)
            
            let normalizedTimePerFrame = (accelerationMagnitude - minAccelerationMagnitude) / (maxAccelerationMagnitude - minAccelerationMagnitude) * (maxTimePerFrame - minTimePerFrame) + minTimePerFrame
            
//            print("normalized: ", normalizedTimePerFrame)
//            print("textureArray: ", textureArray)
            
            // Only update the animation if the acceleration magnitude changes significantly
            if abs(accelerationMagnitude - lastAccelerationMagnitude) > 0.05 {
                if isAnimationRunning {
                    if slime.action(forKey: "animationAction") != nil {
                        let updatedAction = SKAction.animate(with: textureArray, timePerFrame: normalizedTimePerFrame)
                        slime.run(updatedAction, withKey: "animationAction")
                    }
                } else {
                    // Start the animation only if it's not running yet
                    let animationAction = SKAction.animate(with: textureArray, timePerFrame: normalizedTimePerFrame)
                    let repeatAction = SKAction.repeatForever(animationAction)
                    slime.run(repeatAction, withKey: "animationAction")
                    isAnimationRunning = true
                }
                
                lastAccelerationMagnitude = accelerationMagnitude
            }
            
            
        }
        
        
    }
    
    // Stop accelerometer updates when the scene is removed
    deinit {
        manager.stopAccelerometerUpdates()
    }
    
}

struct GameView: View {
    let displaySize: CGRect = UIScreen.main.bounds
    
    var scene: SKScene {
        let scene = GameScene()
        
        scene.size = CGSize(width: displaySize.width, height: displaySize.height)
        scene.scaleMode = .fill
        scene.backgroundColor = SKColor(red: 0.40392, green: 0.13333, blue: 0.384314, alpha: 1.0)
        
        return scene
    }
    
    var body: some View {
        VStack{
            Spacer()
            SpriteView(scene: scene)
                .frame(width: displaySize.width, height: displaySize.height)
                .ignoresSafeArea(.all)
                .edgesIgnoringSafeArea(.all)
            //            .onAppear{
            //            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
