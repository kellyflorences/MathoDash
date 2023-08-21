//
//  GameData.swift
//  MathoDash
//
//  Created by Clarissa Angelia on 11/08/23.
//

import Foundation
import GameKit


enum State: UInt, Codable{
    case lobby = 0
    case startGame = 1
    case endOfRound = 2
    case endOfGame = 3
}



struct GameData: Codable{
    
//    Player Data
    var HostPlayerData : Player?
    var PlayerPlayerData : Player?
    
//    Game State
    var gameState : State
    
    var startGame : StartGame?
    
    var endOfRound : EndOfRound?
    
}
