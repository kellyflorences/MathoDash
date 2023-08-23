//
//  MatchManager.swift
//  MathoDash
//
//  Created by Kelly Florences Tanjaya on 01/08/23.
//

import Foundation
import GameKit
import SwiftUI

enum Role : Int, Codable {
    case host
    case player
}

struct Player: Codable{
    let gamePlayerID: String
    var role: Role
}

class MatchManager: UIViewController, ObservableObject, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKLocalPlayerListener, GKMatchDelegate{
    
    @Published var isGameOver = false
    
    @Published var gameState = GameState.lobby
    
    var match: GKMatch?
    var otherPlayer: GKPlayer?
    let localPlayer = GKLocalPlayer.local
    
    //    player data
//    var players: [Player] = []
   @Published var localPlayerData : Player = Player(gamePlayerID: GKLocalPlayer.local.gamePlayerID, role: Role.player)
   @Published var otherPlayerData : Player?
//
    var opponentAvatar: Image?
    
//    position variable
    @Published var opponentPosition = CGPoint()
    @Published var myPosition = CGPoint()
    
    var loader = LoadMaze()
    
//    round indicator
    var round = 1
    
//    Score Variable
    var scores : [Int] = [0, 0]
    
//    gameData
    var coreGameData : GameData?
    
//    flag to start new round
    @Published var newRound : Bool = false
    
//    flag to track once the game EndOfRound. only once in update.
    @Published var alreadyEnded : Bool = false
    
    var playerUUIDKey = UUID().uuidString
    
    var rootViewController: UIViewController?{
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    func authenticateUser() {
        print("trululu")
        localPlayer.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            GKAccessPoint.shared.isActive = self.localPlayer.isAuthenticated
            //            self.matchMaking()
        }
        GKLocalPlayer.local.register(self)
        
    }
    
    func matchMaking(){
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        // local player = host
        localPlayerData.role = Role.host
        
        //        Make Multiplayer Room
        if let viewController = GKMatchmakerViewController(matchRequest: request) {
            viewController.matchmakerDelegate = self
            rootViewController?.present(viewController, animated: true) { }
        }
        
    }
    
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        // Present the matchmaker view controller in the invitation state.
        if let viewController = GKMatchmakerViewController(invite: invite) {
            viewController.matchmakerDelegate = self
            rootViewController?.present(viewController, animated: true) { }
        }
    }
    
    
    
    func findMatch(for request: GKMatchRequest, withCompletionHandler completionHandler: ((GKMatch?, Error?) -> Void)? = nil) async{
        // Start automatch.
        print("auto match")
        do {
            match = try await GKMatchmaker.shared().findMatch(for: request)
        } catch {
            print("Error: \(error.localizedDescription).")
            return
        }
    }
    
    func findPlayers(
        forHostedRequest request: GKMatchRequest,
        withCompletionHandler completionHandler: (([GKPlayer]?, Error?) -> Void)? = nil
    ){
        print("finding players")
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        print("match making done, passing to game view")
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        print("match making cancelled")
        localPlayerData.role = Role.player
        viewController.dismiss(animated:true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print("start game")
        // Dismiss the view controller.
        viewController.dismiss(animated: true, completion: nil)

        // Set the match delegate.
        //        match.delegate = myGame
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        print("State: ", state)
        switch state {
        case .connected:
            // Load the opponent's avatar.
            player.loadPhoto(for: GKPlayer.PhotoSize.small) { (image, error) in
                if let image {
                    self.opponentAvatar = Image(uiImage: image)
                }
                else if let error {
                    print("Error: \(error.localizedDescription).")
                }
            }
        case .disconnected:
            let alert = UIAlertController(title: "Player Disconnected", message: "The other player disconnected from the game. ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.match?.disconnect()
                
                //reset game here
            })
        default:
            print("default")
        }
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        self.match = match
        match.delegate = self
        
//        get Opponent Data
        otherPlayer = match.players.first
        otherPlayerData = Player(gamePlayerID: otherPlayer!.gamePlayerID, role: Role.player)
        
        // cek role
        // Kalau host, send gameData
        if localPlayerData.role == .host {
            
            //        Load game maps
            loader.loadMazeRound()
            
//            set starting point on host device
            myPosition = CGPoint(x: (Double(UIScreen.main.bounds.width/2) - Double(loader.squareMinSize)), y: Double(loader.squareMinSize*1.5) + Double(loader.squareMinSize))
            
            opponentPosition = CGPoint(x: (Double(UIScreen.main.bounds.width/2) + Double(loader.squareMinSize)), y: Double(loader.squareMinSize*1.5) + Double(loader.squareMinSize))
            
            print("myPos mm : ", myPosition)
            print("enemyPos mm : ", opponentPosition)
//            get starting point coordinate
            let myPositionX = (myPosition.x - loader.marginLeft) / CGFloat(loader.squareMinSize)
            let myPositionY = (myPosition.y - loader.marginBottom) / CGFloat(loader.squareMinSize)
            
            let opponentPositionX = (opponentPosition.x - loader.marginLeft) / CGFloat(loader.squareMinSize)
            let opponentPositionY = (opponentPosition.y - loader.marginBottom) / CGFloat(loader.squareMinSize)
            
//            generate gameData
            coreGameData = GameData(HostPlayerData: localPlayerData, rounds: round, gameState: GameState.startGame, startGame: StartGame(PlayerPosition: CGPoint(x: opponentPositionX, y: opponentPositionY) , HostPosition: CGPoint(x: myPositionX, y: myPositionY), isFinished: false))
            
            //send to other player
            sendGameData(data: coreGameData!)
            
//            set new state
            self.gameState = GameState.startGame
        
        }// else do nothing
        
        if match.expectedPlayerCount == 0 {
            // All players have joined, start the game.
            viewController.dismiss(animated: true, completion: nil)
        }
        
    }
    func sendGameData(data: GameData){
        if let match = match {
            do{
                let gameData = try JSONEncoder().encode(data)
                try match.sendData(toAllPlayers: gameData, with: .reliable)
            } catch{
                print("Error sending data: \(error)")
            }
        }
    }
    
    func handleGameStateChange(gameData: GameData){
//        print("udah nerima state: ", gameData.gameState)
        
        
        if localPlayerData.role == .host{
            print("gameState Host: ", gameData.gameState)
//            Kalau yang menerima host
            switch gameState{
            case .lobby:
                break
                
            case .startGame:
                
                coreGameData = gameData
//                Kalau player sudah selesai
                if gameData.startGame?.isFinished == true {
//                    update Score dll
                    handleRoundWinner(winner: (coreGameData?.PlayerPlayerData!)!)
                    alreadyEnded = true
                    
                }else{
//                    Kalau nggak, update opponentPosition
//                    opponentPosition = gameData.startGame!.PlayerPosition
                    
                }
                break

            case .endOfRound:
//                isHostReady di set di gameView
                if gameData.endOfRound?.isPlayerReady == true && gameData.endOfRound?.isHostReady == true{
                    
                    handleNewRound()
//                    set newRound = true for host
                    newRound = true
                }else if gameData.endOfRound?.isPlayerReady == true && gameData.endOfRound?.isHostReady == false{
//                    modify coreGameData based on receivedData
                    coreGameData?.endOfRound?.isPlayerReady = true
//                    menunggu isHostReady, standby di gameView
                }

                break
            case .endOfGame:
                break
            }
//
            
        }else{
//            Kalau yang menerima player
            print("gameState Player : ", gameData.gameState)
            switch gameState {
            case .lobby:
//                samain coreGameData
                coreGameData = gameData
                
//                samain role
                if localPlayer.gamePlayerID == gameData.HostPlayerData?.gamePlayerID{
                    localPlayerData.role = Role.host
                }else{
                    localPlayerData.role = Role.player
                    coreGameData?.PlayerPlayerData = localPlayerData
                }
                
                //        Load game maps
//                loader.drawBoard()
                loader.loadMazeRound()
                
//                terima starting point coordinate
                opponentPosition = gameData.startGame!.HostPosition
                myPosition = gameData.startGame!.PlayerPosition
                
//                set starting point on player devices
                let opponentPositionX = (opponentPosition.x * CGFloat(loader.squareMinSize)) + loader.marginLeft
                let opponentPositionY = (opponentPosition.y * CGFloat(loader.squareMinSize)) + loader.marginBottom
                
                let myPositionX = (myPosition.x * CGFloat(loader.squareMinSize)) + loader.marginLeft
                let myPositionY = (myPosition.y * CGFloat(loader.squareMinSize)) + loader.marginBottom
                
                opponentPosition = CGPoint(x: opponentPositionX, y: opponentPositionY)
                myPosition = CGPoint(x: myPositionX, y: myPositionY)
                print("myPos mm : ", myPosition)
                print("enemyPos mm : ", opponentPosition)
                
//                Update gameState dari Host --> ke StartGame
                gameState = gameData.gameState
                break
            case .startGame:
//                cek keadaan gameState
                if gameData.gameState == gameState{
                    
//                    Kalau masih sama
    //                update host position di layar
//                    print("opponentPos: ",opponentPosition)
//                    opponentPosition = gameData.startGame!.HostPosition
                }else{
//                    Kalau state beda, update state player
                    print("masuk StartGame")
                    gameState = gameData.gameState
                    alreadyEnded = true
                    coreGameData = gameData
//                    lanjut ngecek button clicked or not di gameView
                }
                break

            case .endOfRound:
                
                if gameData.gameState != gameState{
                    if gameData.gameState == GameState.startGame{
                        
                        round = gameData.rounds!
                        newRound = true
                        print("masuk NewRound")
                    }else{
                        // do smt kalo endofGame
                    }
                    
                    gameState = gameData.gameState
                }
                
//                menerima data if host is ready & menerima data setelah ganti state
                coreGameData = gameData
                
                break
            case .endOfGame:
                break
            }
            
        }

    }
    
//    ==========================================================
//    Update Position using Game Model
//    ==========================================================
//    func updatePosition(){
//        if localPlayerData.role == .host{
//            coreGameData?.startGame?.HostPosition = myPosition
//            sendGameData(data: coreGameData!)
//        }else{
//            coreGameData?.startGame?.PlayerPosition = myPosition
//            sendGameData(data: coreGameData!)
//
//        }
//    }
//    ===========================================================
    
    func handleRoundWinner(winner : Player){
        alreadyEnded = true
//        cek player / host yg manggil functionnya
        if localPlayerData.role == .host{
            
//            Update Score,
//            cek host yang menang / musuh yang menang
            if winner.gamePlayerID == localPlayerData.gamePlayerID{
                scores[0] += 1
            }else{
                scores[1] += 1
            }
                            
//         send data game state yang baru
            coreGameData?.gameState = GameState.endOfRound
            coreGameData?.endOfRound = EndOfRound(roundWinner: winner.gamePlayerID, isPlayerReady: false, isHostReady: false)
                                            
            sendGameData(data: coreGameData!)
            gameState = GameState.endOfRound
            
        }else{
            coreGameData?.startGame?.isFinished = true
            coreGameData?.PlayerPlayerData = localPlayerData
            
            sendGameData(data: coreGameData!)
        }
            

    }
    
    func handleNewRound(){
        if localPlayerData.role == Role.host{
            
            
//            reset isPlayerReady
            coreGameData?.endOfRound?.isPlayerReady = false
            
//          set new rounds
            round += 1
            
//          set new data (Start Game)
            gameState = GameState.startGame
            coreGameData?.rounds = round
            coreGameData?.gameState = gameState
            sendGameData(data: coreGameData!)
        }else{
            // sementara do nothing dulu klo player.. 
        }
    }
    
    //    MARK: GKMatchDelegate
    
    //after matchmaking
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {

       
        // Check if the data is a NSKeyedArchiver
        if let receivedPosition = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: data) as? CGPoint {
//            get opponent ball coordinate
            opponentPosition = receivedPosition
            return
        }else{
//            Else it will be gameData
    //        Receiving data
            do{
                let gameData = try JSONDecoder().decode(GameData.self, from: data)
                handleGameStateChange(gameData: gameData)
                
            } catch{
//                print("Error receiving data: \(error)")
            }
        }
        
 
    }

    func sendBallPosition(position: CGPoint) {
        if let match = match {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: position, requiringSecureCoding: false)
                try match.sendData(toAllPlayers: data, with: .reliable)
            } catch {
//                print("Error sending data: \(error)")
            }
        }
    }
    
}

