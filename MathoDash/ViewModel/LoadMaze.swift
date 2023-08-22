//
//  LoadMaze.swift
//  MazeDemo2
//
//  Created by Kelly Florences Tanjaya on 10/08/23.
//

import Foundation
import UIKit
import SpriteKit

class LoadMaze: ObservableObject{
    var round: Int = 1
    var solver = MathSolver()
    var question: String = ""
    
    
    var squareMinSize: Float = 0.0
    var mazeGrid = SKSpriteNode()
    var mazeObstacles = SKSpriteNode()
    var pinggiranMap = SKSpriteNode()
    var answers = SKLabelNode()
    
    var finishPoints: [CGPoint] = []
    var answerIndex: Int = -1
    
    var marginLeft: CGFloat!
    var marginBottom: CGFloat!
    
    
    func setSquareMinSize(){
        //Get the minimum value for the square size based on the device's ratio size
        let minHeight = UIScreen.main.bounds.height / CGFloat(13)
        let minWidth = UIScreen.main.bounds.width / CGFloat(17)
        
        squareMinSize = Float(min(minHeight, minWidth))
    }
    
    func loadChessBG(){
        //load chess bg
        let node_chess = SKSpriteNode(imageNamed: "chess")
        let size_chess = CGSize(width: CGFloat(squareMinSize * 15), height: CGFloat(squareMinSize * 10))
        node_chess.size = size_chess
        node_chess.name = "wall"
        node_chess.anchorPoint = CGPoint(x: 0.5, y: 0)
        node_chess.position = CGPoint(x: CGFloat(UIScreen.main.bounds.width/2) , y: CGFloat(squareMinSize))
        node_chess.zPosition = 0
        pinggiranMap.addChild(node_chess)
        
        self.marginLeft = UIScreen.main.bounds.width/2 - size_chess.width/2
        self.marginBottom = UIScreen.main.bounds.height/2 - size_chess.height/2
    }
    
    func createObstacles(position: CGPoint, name: String){
        //Obstacle
        var node = SKSpriteNode()
        
        //set asset gambar
        if(name == "finish_correct"){
            node = SKSpriteNode(imageNamed: "finish")
        } else if(name != "purplewall"){
            node = SKSpriteNode(imageNamed: name)
        }
        
        let size = CGSize(width: CGFloat(squareMinSize), height: CGFloat(squareMinSize))
        node.size = size
        
        //set node name
        if(name == "wall2" || name == "purplewall"){
            node.name = "wall"
        }else{
            node.name = name
        }
        
        node.position = position
        node.physicsBody = SKPhysicsBody(rectangleOf: size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.isDynamic = false
        
        //set collision type
        if(name == "spike"){
            node.physicsBody?.categoryBitMask = CollisionTypes.spike.rawValue
        }else if(name == "finish"){
            node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        }else if(name == "finish_correct"){
            node.physicsBody?.categoryBitMask = CollisionTypes.finish_correct.rawValue
            
        }
        else{
            node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        }
        node.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.contactTestBitMask = 0
        node.zPosition = 0.9
        mazeObstacles.addChild(node)
                
    }
    
    func loadMazeRound() {
        //set square min size
        self.setSquareMinSize()
        self.loadChessBG()
        
        let fileNameRound = "round" + String(self.round)
        
        //load pinggiran map
        let node = SKSpriteNode(texture: SKTexture(imageNamed:fileNameRound))
        let size = CGSize(width: CGFloat(squareMinSize * 17), height: CGFloat(squareMinSize * 12.76))
        node.size = size

        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.position = CGPoint(x: CGFloat(UIScreen.main.bounds.width/2) , y: CGFloat(UIScreen.main.bounds.height/2))

        pinggiranMap.addChild(node)
        
        //load obstacles
        guard let levelURL = Bundle.main.url(forResource: fileNameRound, withExtension: "txt") else {
            fatalError("Could not find " + fileNameRound + ".txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }

        let lines = levelString.components(separatedBy: "\n")
        
        var rowCount = 0
        var colCount = 0
        
        //get offset to center the maze
        let yOffset: CGFloat = CGFloat(-squareMinSize*0.5)
        let xOffset: CGFloat = UIScreen.main.bounds.width/2 - CGFloat(squareMinSize)*8
        
        let squareSize = CGSize(width: CGFloat(squareMinSize), height: CGFloat(squareMinSize))

        answerIndex = Int.random(in: 0..<3)
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: CGFloat(column) * squareSize.width + xOffset, y: CGFloat(row) * squareSize.height + yOffset)
                if letter == "X" {
                    // load wall
                    createObstacles(position: position, name: "wall")
                } else if letter == "S"  {
                    // load vortex
                    createObstacles(position: position, name: "spike")
                } else if letter == "W"  {
                    // load wall 2
                    createObstacles(position: position, name: "wall2")
                }
                else if letter == "F" {
                    // load finish
                    finishPoints.append(position)
                    
                    if(finishPoints.count == answerIndex + 1){
                        //correct finish
                        createObstacles(position: position, name: "finish_correct")
                    }else{
                        //wrong answer
                        createObstacles(position: position, name: "finish")
                    }
                }else if letter == "P"{
                    createObstacles(position: position, name: "purplewall")
                }
                else if letter == " " {
                    // this is an empty space – do nothing!
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
                colCount += 1
            }
            rowCount += 1
        }
    }
    
    func loadAnswers(){
        answers.removeAllChildren()
        solver.generateQuestion()
        self.question = solver.question
                
        var aDone = false
        
        for i in 0..<3 {
            let ans = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
            ans.fontSize = 20
            ans.position = CGPoint(x: finishPoints[i].x, y: finishPoints[i].y + CGFloat(squareMinSize / 1.8))
            ans.zPosition = 1
            if(i == answerIndex){
                ans.text = "bnr" + solver.answer
            }else{
                if(!aDone){
                    ans.text = solver.choiceA
                    aDone = true
                }else{
                    ans.text = solver.choiceB
                }
            }
            answers.addChild(ans)
        }
        
        let qstn = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        qstn.fontSize = 20
        qstn.position = CGPoint(x: CGFloat(squareMinSize * 3), y: UIScreen.main.bounds.height - CGFloat(squareMinSize))
        qstn.zPosition = 1
        qstn.text = solver.question
        answers.addChild(qstn)
        
    }
    
//    func setupMaze() {
//        guard let mazeImage = UIImage(named: "maze.png") else { return }
//        let mazeNode = SKSpriteNode(imageNamed: "maze.png")
//        mazeNode.position = CGPoint(x: 1119 / 2, y: 838 / 2)
//        addChild(mazeNode)
//
//        let transparentPaths = extractTransparentPath(from: mazeImage)
//        for path in transparentPaths {
//            let physicsBody = SKPhysicsBody(edgeLoopFrom: path)
//            physicsBody.isDynamic = false
//            mazeNode.physicsBody = physicsBody
//        }
//    }

    func extractTransparentPath(from image: UIImage) -> [CGPath] {
        guard let cgImage = image.cgImage else { return [] }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData: [UInt8] = Array(repeating: 0, count: width * height * 4)
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: bitmapInfo) else { return [] }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var paths: [CGPath] = []
        let gridCellSize: CGFloat = CGFloat(squareMinSize) // Change this to match the size of your grid cells

        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (width * y + x) * 4
                let alpha = pixelData[pixelIndex + 3]

                if alpha == 0 { // If the pixel is transparent
                    let path = UIBezierPath(rect: CGRect(x: CGFloat(x) * gridCellSize, y: CGFloat(y) * gridCellSize, width: gridCellSize, height: gridCellSize))
                    paths.append(path.cgPath)
                }
            }
        }

        return paths
    }

//    func extractTransparentPath(from image: UIImage) -> [CGPath] {
//        guard let cgImage = image.cgImage else {return []}
//        let width = cgImage.width
//        let height = cgImage.height
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        var pixelData: [UInt8] = Array(repeating: 0, count: width * height * 4)
//        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
//
//        guard let context = CGContext(data: 8pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: bitmapInfo) else {return []}
//        context.draw(cgImage, in CGRect)
//    }
}
