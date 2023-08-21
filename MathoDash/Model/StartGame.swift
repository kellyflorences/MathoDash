//
//  StartGame.swift
//  MathoDash
//
//  Created by Clarissa Angelia on 11/08/23.
//

import Foundation
import GameKit

extension MatchManager{
//    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
//        self.match = match
//        match.delegate = self
//        
//        // if local player adalah host, populate array of players
//        if localPlayerData.role == .host {
//            
//            otherPlayerData = Player(gamePlayerID: match.players.first!.gamePlayerID, role: Role.player)
//            print("OtherPlayers: ", otherPlayerData!)
//            players.append(otherPlayerData!)
//            print("arrayPlayers enemy: ",players)
//            // send array of players to others
//            sendPlayerData(players: players)
//        }
//        
//        // else do nothing
//        if match.expectedPlayerCount == 0 {
//            // All players have joined, start the game.
//            viewController.dismiss(animated: true)
//            self.gameState = State.startGame
//        }
//        
//    }
}

struct StartGame : Codable{
//    variable for player
    var PlayerPosition : CGPoint
    var HostPosition : CGPoint
    var isFinished : Bool
    
//    variable for maps
    
}
