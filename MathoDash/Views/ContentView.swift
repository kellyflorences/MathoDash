//
//  ContentView.swift
//  MathoDash
//
//  Created by Kelly Florences Tanjaya on 01/08/23.
//

import SwiftUI
import SpriteKit
import CoreMotion
import GameKit

struct ContentView: View {
    @StateObject var matchManager = MatchManager()
    
    var body: some View {
        NavigationStack{
            if matchManager.gameState.rawValue == 0 {
                ZStack{
                    //            if matchManager.isGameOver{
                    //                GameOverView(matchManager: matchManager)
                    //            } else{
                    //                GameView(matchManager: matchManager)
                    //            }
                    
                    Button{
                        matchManager.matchMaking()
                    } label: {
                        Text("Multiplayer")
                    }
                }.onAppear{
                    matchManager.authenticateUser()
                }
            } else if matchManager.gameState.rawValue > 0 &&  matchManager.gameState.rawValue  < 3 {
                GameView()
            }

        }
//        VStack {
//            SpriteView(scene: scene)
//                .frame(width: 300, height: 400)
//                .ignoresSafeArea()
//        }
//        .padding()
//        .onAppear {
//            matchManager.authenticateUser()
//        }
    }
    
//    var scene: SKScene {
//        let scene = GameScene()
//        scene.size = CGSize(width: 300, height: 400)
//        scene.scaleMode = .fill
//        return scene
//    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
