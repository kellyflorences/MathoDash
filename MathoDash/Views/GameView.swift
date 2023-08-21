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
    case opponent = 32
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let manager : CMMotionManager = CMMotionManager()
    let loader = LoadMaze()
    let solve = MathSolver()
    var matchManager: MatchManager
    
    //    Sprite init
    //    Sprite setup variable
    var playerTextureArray = [SKTexture]()
    var opponentTextureArray = [SKTexture]()
    var player = SKSpriteNode()
    var opponent = SKSpriteNode()
    var playerName = SKLabelNode()
    var opponentName = SKLabelNode()
    
    var playerStartPos = CGPoint()
    var opponentStartPos = CGPoint()
    
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
    
    // timer countdown
    private var countdownLabel: SKLabelNode!
    private var counter: Int = 7
    private var countdownTimer: Timer?
    
    //alert text for wrong answers
    private var alertLabel: SKLabelNode!
    private var questionLabel: SKLabelNode!
    private var readyBtn: SKSpriteNode!

    
    var dimmed = SKSpriteNode()
    
//    flag to track data transmit
    var isStart = false
    
    init(size: CGSize,matchManager: MatchManager) {
        self.matchManager = matchManager
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        //        Load game maps
//        loader.drawBoard()
        loader.loadMazeRound()
        self.addChild(loader.mazeObstacles)
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.scaleMode = .aspectFill
        self.addChild(loader.pinggiranMap)
        
        //        Set sprite appearance
        setSprite()
        
        //generate question
        loader.loadAnswers()
   
        startCountdown()
        dimBG()
    }
    
    //   Setting up collision between object
    func didBegin(_ contact: SKPhysicsContact){
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
//        print("didBegin sih")
        if nodeA == player {
//            print("masuk nodeA")
            playerCollided(with: nodeB)
        } else if nodeB == player {
//            print("masuk nodeB")
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode){
        if node.name == "spike"{
            
            isStart = false
            player.physicsBody?.isDynamic = false
            player.removeFromParent()
            playerName.removeFromParent()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                self.createPlayer()
                isStart = true
                
            }
        }else if node.name == "finish"{
            print("SALAH WKWK")
            wrongAns()
        }else if node.name == "finish_correct"{
            print("BENAR WKWK")
            doneFinish(win: false) //ini boolean diisi true/false berdasarkan player nya menang ato kalah
        }
    }
    
    func wrongAns(){
        alertLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        alertLabel.text = "Wrong Answer"
        alertLabel.fontSize = 80
        alertLabel.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        alertLabel.zPosition = dimmed.zPosition + 1
        alertLabel.verticalAlignmentMode = .center
        alertLabel.fontColor = UIColor(Color("lightYellow"))
        self.addChild(alertLabel)
        dimBG()
        
        player.physicsBody?.isDynamic = false
        let remove = SKAction.removeFromParent()
        player.run(remove)
        playerName.run(remove)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            rmDimBG()
            createPlayer()
            alertLabel.removeFromParent()
        }
    }
    
    // This method is called in the GameViewController to set the xAcceleration value
    func updateXAcceleration(_ acceleration: CGFloat) {
        xAcceleration = acceleration
    }
    
    func doneFinish(win: Bool){
        alertLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        alertLabel.fontSize = 80
        alertLabel.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 + CGFloat(loader.squareMinSize * 3))
        alertLabel.zPosition = dimmed.zPosition + 1
        alertLabel.verticalAlignmentMode = .center
        alertLabel.fontColor = UIColor(Color("lightYellow"))
        self.addChild(alertLabel)
        dimBG()
        
        player.physicsBody?.isDynamic = false
        let remove = SKAction.removeFromParent()
        player.run(remove)
        playerName.run(remove)
        
        if(win){
            alertLabel.text = "You Win!"
        }else{
            alertLabel.text = "You Lost!"
        }
        
        readyBtn = SKSpriteNode(imageNamed: "ready")
        readyBtn.name = "readyBtn"
        readyBtn.size = CGSize(width: Double(loader.squareMinSize * 8.0), height: Double(loader.squareMinSize * 2.0))
        readyBtn.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - CGFloat(loader.squareMinSize))
        readyBtn.zPosition = alertLabel.zPosition
        self.addChild(readyBtn)
    }
    
    func nextRound(){
        
//        if round masih ada
        if(loader.round < 6){
            loader.round += 1
            matchManager.handleRoundWinner(winner: matchManager.localPlayerData)
            
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
    
    func setSprite(){
//            set water char for host, sun char for player
        if matchManager.localPlayerData.role == .host{

        //        Adding player texture
            for i in 1...5{
                let textureName = "water_\(i)"
                playerTextureArray.append(SKTexture(imageNamed: textureName))
            }
        
//            Adding opponent texture
            for i in 1...5{
                let textureName = "sun_\(i)"
                opponentTextureArray.append(SKTexture(imageNamed: textureName))
            }
            
            
        }else{
            
            for i in 1...5{
                let textureName = "sun_\(i)"
                playerTextureArray.append(SKTexture(imageNamed: textureName))
            }
        
            for i in 1...5{
                let textureName = "water_\(i)"
                opponentTextureArray.append(SKTexture(imageNamed: textureName))
            }
        }
        
    }
    
    func createPlayer(){
        player.removeFromParent()
        
        //        adding player sprite
        if playerTextureArray.count > 1{
            let imageFrame = playerTextureArray.first
            let size = CGFloat(loader.squareMinSize) * 0.9

            player = SKSpriteNode(texture: imageFrame)
//            player.position = CGPoint(x: Double(UIScreen.main.bounds.width/2) - Double(loader.squareMinSize), y: Double(loader.squareMinSize*1.5))
            player.position = playerStartPos
            print("myPos cp: ", matchManager.myPosition)
            player.size = CGSize(width: size, height: size)
//            player.physicsBody = SKPhysicsBody(texture: player.texture!,size: player.texture!.size())
            player.physicsBody = SKPhysicsBody(texture: player.texture!,size: CGSize(width: size, height: size))
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
            player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue | CollisionTypes.opponent.rawValue
            player.physicsBody?.contactTestBitMask = CollisionTypes.spike.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.finish_correct.rawValue
            player.zPosition = 1.0
            addChild(player)
        }
        
        player.run(SKAction.repeatForever(SKAction.animate(with: playerTextureArray, timePerFrame: 0.1)))
        
        //add player name along with the slime
        playerName.removeFromParent()
//        nti di ganti pakai data player
        playerName.text = matchManager.localPlayer.displayName
        playerName.fontName = "AvenirNext-HeavyItalic"
        playerName.color = .white
        playerName.fontSize = 10
        playerName.position = player.position
        playerName.zPosition = player.zPosition
        addChild(playerName)
    }
    
    func createOpponent(){
        //        adding player sprite
        if opponentTextureArray.count > 1{
            let imageFrame = opponentTextureArray.first
            let size = CGFloat(loader.squareMinSize) * 0.9

            opponent = SKSpriteNode(texture: imageFrame)
//            opponent.position = CGPoint(x: Double(UIScreen.main.bounds.width/2) + Double(loader.squareMinSize), y: Double(loader.squareMinSize*1.5))
            opponent.position = opponentStartPos
            print("opponentPos: ", matchManager.opponentPosition)
            opponent.size = CGSize(width: size, height: size)
//            player.physicsBody = SKPhysicsBody(texture: player.texture!,size: player.texture!.size())
            opponent.physicsBody = SKPhysicsBody(texture: opponent.texture!,size: CGSize(width: size, height: size))
            opponent.physicsBody?.allowsRotation = false
            opponent.physicsBody?.affectedByGravity = false
            opponent.physicsBody?.categoryBitMask = CollisionTypes.opponent.rawValue
            opponent.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue | CollisionTypes.player.rawValue
            opponent.physicsBody?.contactTestBitMask = CollisionTypes.spike.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.finish_correct.rawValue
            opponent.zPosition = 1.0
            addChild(opponent)
        }
        
        opponent.run(SKAction.repeatForever(SKAction.animate(with: opponentTextureArray, timePerFrame: 0.1)))
        
        //add opponent name along with the slime
        opponentName.removeFromParent()
//        nti di ganti pakai data player
        opponentName.text = matchManager.otherPlayer!.displayName
        opponentName.fontName = "AvenirNext-HeavyItalic"
        opponentName.color = .white
        opponentName.fontSize = 10
        opponentName.position = opponent.position
        opponentName.zPosition = opponent.zPosition
        addChild(opponentName)
    }
    
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
            playerStartPos = matchManager.myPosition
            opponentStartPos = matchManager.opponentPosition
            self.createPlayer()
            self.createOpponent()
            isStart = true
            self.countdownLabel.removeFromParent()
            self.addChild(loader.answers)
        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if readyBtn.contains(location) {
                // Handle button tap action here
                print("Play button tapped!")
                rmDimBG()
                createPlayer()
                alertLabel.removeFromParent()
                readyBtn.removeFromParent()
                nextRound()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
//        update player name position
        playerName.position = CGPoint(x: player.position.x, y: player.position.y - CGFloat(loader.squareMinSize / 1.5))
        
        if isStart{
            //        get myposition coordinate
            let currentX: CGFloat = (player.position.x  - loader.marginLeft) / CGFloat(loader.squareMinSize)
            let currentY: CGFloat = (player.position.y - loader.marginBottom) / CGFloat(loader.squareMinSize)
            
            //        renew myPosition in coordinate
            matchManager.myPosition = CGPoint(x: currentX, y: currentY)
            
            //        Send ball data to opponent
            //        matchManager.updatePosition()
            
            //        alternate way using NSKeyed:
            //        send our ball coordinate to opponent
            matchManager.sendBallPosition(position: matchManager.myPosition)
            
            //        set opponent ball position in our device
            let opponentX = (matchManager.opponentPosition.x * CGFloat(loader.squareMinSize)) + loader.marginLeft
            let opponentY = ( matchManager.opponentPosition.y * CGFloat(loader.squareMinSize)) + loader.marginBottom
            opponent.position = CGPoint(x: opponentX, y: opponentY)
            opponentName.position = CGPoint(x: opponent.position.x, y: opponent.position.y - CGFloat(loader.squareMinSize / 1.5))

        }
        
    }
    
    // Stop accelerometer updates when the scene is removed
    deinit {
        manager.stopAccelerometerUpdates()
    }
}

struct GameView: View {
    @ObservedObject var matchManager: MatchManager
    let displaySize: CGRect = UIScreen.main.bounds

    var scene: SKScene {
        let scene = GameScene(size: CGSize(width: displaySize.width, height: displaySize.height), matchManager: matchManager)
        
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
        GameView(matchManager: MatchManager())
    }
}
